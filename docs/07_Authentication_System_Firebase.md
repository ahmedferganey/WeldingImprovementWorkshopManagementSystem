# Authentication System - Firebase Integration

**Project**: Welding Improvement Workshop Management System  
**Date**: December 2024  
**Authentication Provider**: Firebase Authentication  
**Purpose**: Comprehensive guide for implementing Firebase Authentication for both backend and frontend

---

## 📋 Table of Contents

1. [Overview](#overview)
2. [Architecture](#architecture)
3. [Firebase Setup](#firebase-setup)
4. [Backend Implementation](#backend-implementation)
5. [Frontend Implementation](#frontend-implementation)
6. [Security Considerations](#security-considerations)
7. [Role-Based Access Control](#role-based-access-control)
8. [Implementation Checklist](#implementation-checklist)

---

## Overview

### Why Firebase Authentication?

- ✅ **Managed Service**: No need to manage user database or password security
- ✅ **Multiple Providers**: Email/Password, Google, etc.
- ✅ **Secure**: Built on Google's infrastructure
- ✅ **Token Management**: Automatic JWT token generation and refresh
- ✅ **Scalable**: Handles millions of users
- ✅ **Easy Integration**: Simple SDK for Flutter and Python

### Authentication Flow

```
┌─────────────┐
│   Frontend  │
│  (Flutter)  │
└──────┬──────┘
       │ 1. User logs in
       ▼
┌─────────────────┐
│  Firebase Auth  │
│  (Google Cloud) │
└──────┬──────────┘
       │ 2. Verify credentials
       │ 3. Generate ID Token
       ▼
┌─────────────┐
│   Frontend  │
│  (Flutter)  │
└──────┬──────┘
       │ 4. Send ID Token to Backend
       ▼
┌─────────────┐
│   Backend   │
│  (FastAPI)  │
└──────┬──────┘
       │ 5. Verify token with Firebase
       │ 6. Extract user info
       │ 7. Check roles/permissions
       ▼
┌─────────────┐
│   Response  │
└─────────────┘
```

---

## Architecture

### Components

1. **Firebase Authentication** (Google Cloud)
   - User management
   - Credential verification
   - Token generation

2. **Backend (FastAPI)**
   - Token verification
   - User info extraction
   - Role-based authorization
   - Protected endpoints

3. **Frontend (Flutter)**
   - Login UI
   - Token storage
   - API request headers
   - Auth state management

### Data Flow

1. User logs in via Flutter app → Firebase Auth
2. Firebase returns ID Token → Flutter app
3. Flutter sends token in API requests → Backend
4. Backend verifies token with Firebase → Valid/Invalid
5. Backend checks user roles → Allow/Deny access

---

## Firebase Setup

### Step 1: Create Firebase Project

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Click "Add project"
3. Enter project name: `weldingworkshop-f4697` (or your project)
4. Enable Google Analytics (optional)
5. Create project

### Step 2: Enable Authentication

1. In Firebase Console → Authentication
2. Click "Get started"
3. Enable **Email/Password** provider:
   - Click "Email/Password"
   - Enable "Email/Password"
   - Enable "Email link (passwordless sign-in)" (optional)
   - Save

4. Enable **Google** provider (optional):
   - Click "Google"
   - Enable Google sign-in
   - Add support email
   - Save

### Step 3: Configure OAuth Consent Screen (for Google)

1. Go to [Google Cloud Console](https://console.cloud.google.com/)
2. Select your Firebase project
3. APIs & Services → OAuth consent screen
4. Configure consent screen
5. Add scopes if needed

### Step 4: Get Firebase Configuration

1. Firebase Console → Project Settings (gear icon)
2. Scroll to "Your apps"
3. Add web app or use existing
4. Copy configuration:

```json
{
  "apiKey": "AIza...",
  "authDomain": "weldingworkshop-f4697.firebaseapp.com",
  "projectId": "weldingworkshop-f4697",
  "storageBucket": "weldingworkshop-f4697.appspot.com",
  "messagingSenderId": "123456789",
  "appId": "1:123456789:web:abc123"
}
```

5. Download service account key (for backend):
   - Project Settings → Service Accounts
   - Generate new private key
   - Save as `firebase-service-account.json`

---

## Backend Implementation

### Step 1: Install Dependencies

```bash
pip install firebase-admin==6.3.0
```

Add to `requirements.txt`:
```txt
firebase-admin==6.3.0
```

### Step 2: Initialize Firebase Admin SDK

**File**: `backend/app/core/firebase_auth.py`

```python
import firebase_admin
from firebase_admin import credentials, auth
from pathlib import Path
import os
from typing import Optional

# Initialize Firebase Admin (singleton)
_firebase_app: Optional[firebase_admin.App] = None

def initialize_firebase():
    """Initialize Firebase Admin SDK"""
    global _firebase_app
    
    if _firebase_app is not None:
        return _firebase_app
    
    # Get service account key path
    service_account_path = os.getenv("FIREBASE_SERVICE_ACCOUNT_PATH")
    
    if not service_account_path:
        raise ValueError("FIREBASE_SERVICE_ACCOUNT_PATH environment variable not set")
    
    if not Path(service_account_path).exists():
        raise FileNotFoundError(f"Firebase service account file not found: {service_account_path}")
    
    # Initialize Firebase Admin
    cred = credentials.Certificate(service_account_path)
    _firebase_app = firebase_admin.initialize_app(cred)
    
    return _firebase_app

def verify_id_token(token: str) -> dict:
    """
    Verify Firebase ID token and return decoded token
    
    Args:
        token: Firebase ID token from frontend
        
    Returns:
        Decoded token with user information
        
    Raises:
        ValueError: If token is invalid
    """
    try:
        # Initialize if not already done
        if _firebase_app is None:
            initialize_firebase()
        
        # Verify and decode token
        decoded_token = auth.verify_id_token(token)
        return decoded_token
    
    except firebase_admin.exceptions.InvalidArgumentError:
        raise ValueError("Invalid token format")
    except firebase_admin.exceptions.ExpiredIdTokenError:
        raise ValueError("Token has expired")
    except firebase_admin.exceptions.RevokedIdTokenError:
        raise ValueError("Token has been revoked")
    except Exception as e:
        raise ValueError(f"Token verification failed: {str(e)}")

def get_user_by_uid(uid: str) -> dict:
    """Get user information from Firebase by UID"""
    try:
        if _firebase_app is None:
            initialize_firebase()
        
        user = auth.get_user(uid)
        return {
            "uid": user.uid,
            "email": user.email,
            "email_verified": user.email_verified,
            "display_name": user.display_name,
            "photo_url": user.photo_url,
            "disabled": user.disabled,
            "metadata": {
                "creation_timestamp": user.user_metadata.creation_timestamp,
                "last_sign_in_timestamp": user.user_metadata.last_sign_in_timestamp,
            }
        }
    except Exception as e:
        raise ValueError(f"Failed to get user: {str(e)}")
```

### Step 3: Create Authentication Dependency

**File**: `backend/app/core/auth_dependencies.py`

```python
from fastapi import Depends, HTTPException, status
from fastapi.security import HTTPBearer, HTTPAuthorizationCredentials
from typing import Optional
from .firebase_auth import verify_id_token
import logging

logger = logging.getLogger("app")
security = HTTPBearer()

async def get_current_user(
    credentials: HTTPAuthorizationCredentials = Depends(security)
) -> dict:
    """
    FastAPI dependency to get current authenticated user
    
    Usage:
        @app.get("/protected")
        async def protected_route(user: dict = Depends(get_current_user)):
            return {"user_id": user["uid"]}
    """
    token = credentials.credentials
    
    try:
        decoded_token = verify_id_token(token)
        
        # Extract user information
        user_info = {
            "uid": decoded_token["uid"],
            "email": decoded_token.get("email"),
            "email_verified": decoded_token.get("email_verified", False),
            "name": decoded_token.get("name"),
        }
        
        return user_info
    
    except ValueError as e:
        logger.warning(f"Token verification failed: {str(e)}")
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Invalid authentication credentials",
            headers={"WWW-Authenticate": "Bearer"},
        )
    except Exception as e:
        logger.error(f"Authentication error: {str(e)}", exc_info=True)
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Authentication failed",
            headers={"WWW-Authenticate": "Bearer"},
        )
```

### Step 4: Create Role-Based Authorization

**File**: `backend/app/core/authorization.py`

```python
from fastapi import HTTPException, status
from typing import List, Optional
from functools import wraps
from .auth_dependencies import get_current_user

# Define roles
ROLES = {
    "admin": ["admin", "manager", "operator", "viewer"],
    "manager": ["manager", "operator", "viewer"],
    "operator": ["operator", "viewer"],
    "viewer": ["viewer"],
}

# Role hierarchy
ROLE_HIERARCHY = {
    "admin": 4,
    "manager": 3,
    "operator": 2,
    "viewer": 1,
}

def get_user_role(uid: str) -> str:
    """
    Get user role from database or Firebase custom claims
    
    Note: For now, using Firebase custom claims.
    Can be enhanced to check database.
    """
    # TODO: Implement role fetching from database
    # For now, default to viewer
    return "viewer"

def require_role(required_roles: List[str]):
    """
    Decorator to require specific roles
    
    Usage:
        @app.get("/admin-only")
        @require_role(["admin", "manager"])
        async def admin_route(user: dict = Depends(get_current_user)):
            return {"message": "Admin access"}
    """
    def decorator(func):
        async def wrapper(*args, user: dict = None, **kwargs):
            if user is None:
                raise HTTPException(
                    status_code=status.HTTP_401_UNAUTHORIZED,
                    detail="Authentication required"
                )
            
            user_role = get_user_role(user["uid"])
            
            # Check if user has required role
            allowed_roles = set()
            for role in required_roles:
                allowed_roles.update(ROLES.get(role, [role]))
            
            if user_role not in allowed_roles:
                raise HTTPException(
                    status_code=status.HTTP_403_FORBIDDEN,
                    detail=f"Access denied. Required roles: {required_roles}"
                )
            
            return await func(*args, user=user, **kwargs)
        
        return wrapper
    return decorator

def require_min_role(min_role: str):
    """
    Require minimum role level
    
    Usage:
        @app.post("/create")
        @require_min_role("operator")
        async def create_item(user: dict = Depends(get_current_user)):
            ...
    """
    def decorator(func):
        async def wrapper(*args, user: dict = None, **kwargs):
            if user is None:
                raise HTTPException(
                    status_code=status.HTTP_401_UNAUTHORIZED,
                    detail="Authentication required"
                )
            
            user_role = get_user_role(user["uid"])
            min_level = ROLE_HIERARCHY.get(min_role, 0)
            user_level = ROLE_HIERARCHY.get(user_role, 0)
            
            if user_level < min_level:
                raise HTTPException(
                    status_code=status.HTTP_403_FORBIDDEN,
                    detail=f"Access denied. Minimum role required: {min_role}"
                )
            
            return await func(*args, user=user, **kwargs)
        
        return wrapper
    return decorator
```

### Step 5: Protect Endpoints

**File**: `backend/app/main.py` (update)

```python
from fastapi import FastAPI, Depends
from app.core.auth_dependencies import get_current_user
from app.core.authorization import require_role, require_min_role

# Initialize Firebase on startup
@app.on_event("startup")
async def on_start():
    from app.core.firebase_auth import initialize_firebase
    try:
        initialize_firebase()
        logger.info("Firebase initialized successfully")
    except Exception as e:
        logger.error(f"Firebase initialization failed: {e}")
    
    scheduler.start_scheduler()

# Protected endpoint example
@app.get("/machines")
async def list_machines(
    db: AsyncSession = Depends(get_db),
    user: dict = Depends(get_current_user)  # Require authentication
):
    return await crud.list_machines(db)

# Role-based endpoint example
@app.post("/machines")
@require_min_role("operator")  # Require operator or higher
async def create_machine(
    body: MachineCreate,
    db: AsyncSession = Depends(get_db),
    user: dict = Depends(get_current_user)
):
    return await crud.create_machine(db, body)

# Admin-only endpoint example
@app.delete("/machines/{machine_id}")
@require_role(["admin"])  # Admin only
async def delete_machine(
    machine_id: int,
    db: AsyncSession = Depends(get_db),
    user: dict = Depends(get_current_user)
):
    return await crud.delete_machine(db, machine_id)
```

### Step 6: Create Auth Endpoints

**File**: `backend/app/api/v1/endpoints/auth.py`

```python
from fastapi import APIRouter, Depends, HTTPException, status
from app.core.auth_dependencies import get_current_user

router = APIRouter()

@router.get("/me")
async def get_current_user_info(user: dict = Depends(get_current_user)):
    """Get current authenticated user information"""
    return {
        "uid": user["uid"],
        "email": user["email"],
        "email_verified": user.get("email_verified", False),
        "name": user.get("name"),
    }

@router.post("/verify-token")
async def verify_token(user: dict = Depends(get_current_user)):
    """Verify if token is valid"""
    return {"valid": True, "user": user}
```

### Step 7: Environment Configuration

**File**: `backend/.env`

```bash
# Firebase Configuration
FIREBASE_SERVICE_ACCOUNT_PATH=./firebase-service-account.json
FIREBASE_PROJECT_ID=weldingworkshop-f4697
```

---

## Frontend Implementation

### Step 1: Install Dependencies

**File**: `improvementworkshop/pubspec.yaml`

```yaml
dependencies:
  # Existing dependencies...
  
  # Firebase Authentication
  firebase_core: ^2.24.2
  firebase_auth: ^4.15.3
  
  # Token Storage
  shared_preferences: ^2.2.2
```

Run:
```bash
cd improvementworkshop
flutter pub get
```

### Step 2: Configure Firebase

**File**: `improvementworkshop/lib/config/firebase_config.dart`

```dart
class FirebaseConfig {
  // Firebase configuration
  static const Map<String, String> config = {
    "apiKey": "AIza...",
    "authDomain": "weldingworkshop-f4697.firebaseapp.com",
    "projectId": "weldingworkshop-f4697",
    "storageBucket": "weldingworkshop-f4697.appspot.com",
    "messagingSenderId": "123456789",
    "appId": "1:123456789:web:abc123"
  };
}
```

**File**: `improvementworkshop/lib/main.dart` (update)

```dart
import 'package:firebase_core/firebase_core.dart';
import 'config/firebase_config.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase
  await Firebase.initializeApp(
    options: FirebaseOptions(
      apiKey: FirebaseConfig.config['apiKey']!,
      appId: FirebaseConfig.config['appId']!,
      messagingSenderId: FirebaseConfig.config['messagingSenderId']!,
      projectId: FirebaseConfig.config['projectId']!,
      authDomain: FirebaseConfig.config['authDomain']!,
      storageBucket: FirebaseConfig.config['storageBucket']!,
    ),
  );
  
  runApp(
    ChangeNotifierProvider(
      create: (_) => AppProvider(),
      child: const WeldingWorkshopApp(),
    ),
  );
}
```

### Step 3: Create Auth Service

**File**: `improvementworkshop/lib/services/auth_service.dart`

```dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  
  // Get current user
  User? get currentUser => _auth.currentUser;
  
  // Auth state stream
  Stream<User?> get authStateChanges => _auth.authStateChanges();
  
  // Sign in with email and password
  Future<UserCredential> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      // Store token
      await _storeToken(credential.user);
      
      return credential;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }
  
  // Sign up with email and password
  Future<UserCredential> signUpWithEmailAndPassword({
    required String email,
    required String password,
    String? displayName,
  }) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      // Update display name if provided
      if (displayName != null && credential.user != null) {
        await credential.user!.updateDisplayName(displayName);
        await credential.user!.reload();
      }
      
      // Store token
      await _storeToken(credential.user);
      
      return credential;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }
  
  // Sign in with Google (optional)
  Future<UserCredential> signInWithGoogle() async {
    // TODO: Implement Google Sign-In
    // Requires google_sign_in package
    throw UnimplementedError('Google Sign-In not yet implemented');
  }
  
  // Sign out
  Future<void> signOut() async {
    await _auth.signOut();
    await _clearToken();
  }
  
  // Get ID Token
  Future<String?> getIdToken({bool forceRefresh = false}) async {
    final user = _auth.currentUser;
    if (user == null) return null;
    
    try {
      return await user.getIdToken(forceRefresh);
    } catch (e) {
      return null;
    }
  }
  
  // Store token in shared preferences
  Future<void> _storeToken(User? user) async {
    if (user == null) return;
    
    try {
      final token = await user.getIdToken();
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('firebase_id_token', token);
    } catch (e) {
      // Token storage failed, but not critical
    }
  }
  
  // Clear stored token
  Future<void> _clearToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('firebase_id_token');
  }
  
  // Handle auth exceptions
  String _handleAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return 'No user found with this email.';
      case 'wrong-password':
        return 'Wrong password provided.';
      case 'email-already-in-use':
        return 'An account already exists with this email.';
      case 'weak-password':
        return 'The password provided is too weak.';
      case 'invalid-email':
        return 'The email address is invalid.';
      case 'user-disabled':
        return 'This user account has been disabled.';
      case 'too-many-requests':
        return 'Too many failed attempts. Please try again later.';
      default:
        return 'Authentication failed: ${e.message}';
    }
  }
}
```

### Step 4: Create Auth Provider

**File**: `improvementworkshop/lib/providers/auth_provider.dart`

```dart
import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();
  
  User? _user;
  bool _isLoading = false;
  String? _errorMessage;
  
  User? get user => _user;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _user != null;
  
  AuthProvider() {
    // Listen to auth state changes
    _authService.authStateChanges.listen((user) {
      _user = user;
      notifyListeners();
    });
    
    // Initialize with current user
    _user = _authService.currentUser;
  }
  
  // Sign in
  Future<bool> signIn(String email, String password) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();
      
      await _authService.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      _user = _authService.currentUser;
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
  
  // Sign up
  Future<bool> signUp(String email, String password, {String? displayName}) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();
      
      await _authService.signUpWithEmailAndPassword(
        email: email,
        password: password,
        displayName: displayName,
      );
      
      _user = _authService.currentUser;
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
  
  // Sign out
  Future<void> signOut() async {
    try {
      _isLoading = true;
      notifyListeners();
      
      await _authService.signOut();
      _user = null;
      
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }
  
  // Get ID Token
  Future<String?> getIdToken() async {
    return await _authService.getIdToken();
  }
}
```

### Step 5: Create Login Screen

**File**: `improvementworkshop/lib/screens/login_screen.dart`

```dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isSignUp = false;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    final authProvider = context.read<AuthProvider>();
    bool success;

    if (_isSignUp) {
      success = await authProvider.signUp(
        _emailController.text.trim(),
        _passwordController.text,
      );
    } else {
      success = await authProvider.signIn(
        _emailController.text.trim(),
        _passwordController.text,
      );
    }

    if (!mounted) return;

    if (success) {
      // Navigation handled by auth state listener
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(authProvider.errorMessage ?? 'Authentication failed'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Logo/Title
                  Icon(
                    Icons.precision_manufacturing,
                    size: 80,
                    color: Colors.blue.shade900,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Welding Workshop',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 48),

                  // Email field
                  TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(
                      labelText: 'Email',
                      prefixIcon: Icon(Icons.email),
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your email';
                      }
                      if (!value.contains('@')) {
                        return 'Please enter a valid email';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Password field
                  TextFormField(
                    controller: _passwordController,
                    obscureText: _obscurePassword,
                    decoration: InputDecoration(
                      labelText: 'Password',
                      prefixIcon: const Icon(Icons.lock),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword
                              ? Icons.visibility
                              : Icons.visibility_off,
                        ),
                        onPressed: () {
                          setState(() {
                            _obscurePassword = !_obscurePassword;
                          });
                        },
                      ),
                      border: const OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your password';
                      }
                      if (value.length < 6) {
                        return 'Password must be at least 6 characters';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),

                  // Submit button
                  Consumer<AuthProvider>(
                    builder: (context, authProvider, child) {
                      return SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed:
                              authProvider.isLoading ? null : _handleSubmit,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue.shade900,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                          child: authProvider.isLoading
                              ? const CircularProgressIndicator(
                                  color: Colors.white,
                                )
                              : Text(_isSignUp ? 'Sign Up' : 'Sign In'),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 16),

                  // Toggle sign up/sign in
                  TextButton(
                    onPressed: () {
                      setState(() {
                        _isSignUp = !_isSignUp;
                      });
                    },
                    child: Text(
                      _isSignUp
                          ? 'Already have an account? Sign In'
                          : 'Don\'t have an account? Sign Up',
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
```

### Step 6: Update API Service to Include Token

**File**: `improvementworkshop/lib/services/api_service.dart` (update)

```dart
import '../providers/auth_provider.dart';

class ApiService {
  final AuthService _authService = AuthService();
  
  // Helper to get headers with auth token
  Future<Map<String, String>> _getHeaders() async {
    final headers = {
      'Content-Type': 'application/json',
    };
    
    // Add auth token if available
    final token = await _authService.getIdToken();
    if (token != null) {
      headers['Authorization'] = 'Bearer $token';
    }
    
    return headers;
  }
  
  // Update all HTTP methods to use auth headers
  Future<List<T>> _getList<T>(
    String url,
    T Function(Map<String, dynamic>) fromJson,
  ) async {
    try {
      final headers = await _getHeaders();
      final response = await http
          .get(Uri.parse(url), headers: headers)
          .timeout(ApiConfig.connectionTimeout);

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((item) => fromJson(item as Map<String, dynamic>)).toList();
      } else if (response.statusCode == 401) {
        throw Exception('Unauthorized. Please log in again.');
      } else {
        throw Exception('Failed to load data: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }
  
  // Similar updates for _post, _put, _delete methods...
}
```

### Step 7: Update Main App with Auth Guard

**File**: `improvementworkshop/lib/main.dart` (update)

```dart
import 'package:firebase_core/firebase_core.dart';
import 'providers/auth_provider.dart';
import 'screens/login_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase
  await Firebase.initializeApp(...);
  
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => AppProvider()),
      ],
      child: const WeldingWorkshopApp(),
    ),
  );
}

class WeldingWorkshopApp extends StatelessWidget {
  const WeldingWorkshopApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Welding Workshop Management',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(...),
      home: const AuthWrapper(),
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        if (authProvider.isLoading) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        
        if (authProvider.isAuthenticated) {
          return const MainScreen();
        } else {
          return const LoginScreen();
        }
      },
    );
  }
}
```

---

## Security Considerations

### Backend Security

1. **Token Verification**: Always verify tokens server-side
2. **HTTPS Only**: Require HTTPS in production
3. **Token Expiry**: Tokens expire automatically (1 hour default)
4. **CORS Configuration**: Only allow frontend domain
5. **Rate Limiting**: Implement rate limiting on auth endpoints

### Frontend Security

1. **Token Storage**: Use secure storage (SharedPreferences is okay for web)
2. **HTTPS**: Always use HTTPS in production
3. **Token Refresh**: Automatically refresh expired tokens
4. **Logout**: Clear tokens on logout
5. **Error Handling**: Don't expose sensitive error details

---

## Role-Based Access Control

### Setting User Roles

**Option 1: Firebase Custom Claims** (Recommended for small teams)

```python
# Backend script to set user role
from firebase_admin import auth

# Set admin role
auth.set_custom_user_claims(uid, {"role": "admin"})

# Set manager role
auth.set_custom_user_claims(uid, {"role": "manager"})
```

**Option 2: Database Roles** (Recommended for production)

Create a `user_roles` table:
- user_id (Firebase UID)
- role (admin, manager, operator, viewer)
- created_at
- updated_at

---

## Implementation Checklist

### Firebase Setup
- [ ] Create Firebase project
- [ ] Enable Email/Password authentication
- [ ] Enable Google authentication (optional)
- [ ] Download service account key
- [ ] Get Firebase configuration

### Backend Implementation
- [ ] Install firebase-admin
- [ ] Initialize Firebase Admin SDK
- [ ] Create token verification function
- [ ] Create auth dependencies
- [ ] Create authorization helpers
- [ ] Protect endpoints
- [ ] Create auth endpoints
- [ ] Add environment variables
- [ ] Test token verification

### Frontend Implementation
- [ ] Install Firebase packages
- [ ] Initialize Firebase
- [ ] Create auth service
- [ ] Create auth provider
- [ ] Create login screen
- [ ] Update API service with tokens
- [ ] Add auth guard
- [ ] Test authentication flow

### Testing
- [ ] Test login
- [ ] Test sign up
- [ ] Test logout
- [ ] Test token refresh
- [ ] Test protected endpoints
- [ ] Test role-based access

---

## Troubleshooting

### Common Issues

1. **Token Verification Fails**
   - Check service account key path
   - Verify Firebase project ID
   - Check token format

2. **CORS Errors**
   - Update CORS configuration in backend
   - Add frontend URL to allowed origins

3. **Token Expired**
   - Implement token refresh
   - Handle 401 errors gracefully

---

**Document Version**: 1.0  
**Created**: December 2024  
**Status**: Ready for Implementation

