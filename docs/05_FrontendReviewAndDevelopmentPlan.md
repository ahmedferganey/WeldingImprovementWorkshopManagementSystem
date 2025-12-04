# Frontend Review & Development Plan

**Project**: Welding Improvement Workshop Management System - Frontend  
**Date**: December 2024  
**Purpose**: Comprehensive review of frontend implementation and development plan aligned with backend

---

## 📋 Table of Contents

1. [Frontend Current State Assessment](#frontend-current-state-assessment)
2. [Backend Integration Analysis](#backend-integration-analysis)
3. [Missing Features & Gaps](#missing-features--gaps)
4. [Frontend Development Plan](#frontend-development-plan)
5. [Implementation Tasks](#implementation-tasks)

---

## Frontend Current State Assessment

### ✅ What's Implemented

#### Core Architecture
- ✅ Flutter Web application structure
- ✅ Provider state management
- ✅ Navigation with NavigationRail
- ✅ 7 main screens implemented
- ✅ API service layer with HTTP client
- ✅ Model classes for all resources

#### Screens Implemented
1. ✅ **Dashboard Screen** - Statistics cards, charts, low stock table
2. ✅ **Work Orders Screen** - List view, create dialog
3. ✅ **Equipment Screen** - List view, create dialog
4. ✅ **Inspections Screen** - List view, create dialog
5. ✅ **Employees Screen** - List view, create dialog
6. ✅ **Inventory Screen** - List view, create dialog
7. ✅ **Machines Screen** - List view, create dialog

#### API Integration
- ✅ GET endpoints for all resources (list)
- ✅ POST endpoints for all resources (create)
- ✅ File upload endpoint
- ✅ Error handling basics
- ✅ Loading states

#### UI/UX Features
- ✅ Material Design 3
- ✅ Responsive layout
- ✅ Charts (FL Chart)
- ✅ Data tables
- ✅ Form dialogs for creation
- ✅ Status chips with colors
- ✅ Refresh functionality

---

### ❌ What's Missing

#### CRUD Operations
- ❌ **GET by ID** - No way to fetch single resource
- ❌ **UPDATE (PUT/PATCH)** - No update/edit functionality
- ❌ **DELETE** - No delete functionality
- ❌ **Detail views** - No individual resource detail pages

#### API Features
- ❌ **Pagination** - Loading all data at once
- ❌ **Filtering** - No filter/search capabilities
- ❌ **Sorting** - No sorting options
- ❌ **Dashboard API** - Stats calculated client-side, not from backend endpoint

#### Authentication & Security
- ❌ **Authentication** - No login/auth system
- ❌ **Token management** - No JWT token handling
- ❌ **Authorization** - No role-based UI
- ❌ **Protected routes** - All screens accessible

#### Error Handling
- ❌ **Comprehensive error handling** - Basic try-catch only
- ❌ **Error display** - Limited error messages
- ❌ **Network error handling** - Generic error messages
- ❌ **Retry mechanisms** - No retry on failure

#### User Experience
- ❌ **Edit dialogs** - Only create dialogs exist
- ❌ **Delete confirmations** - No delete functionality
- ❌ **Detail views** - No detail pages
- ❌ **Bulk operations** - No multi-select/actions
- ❌ **Search/Filter UI** - No search bars or filters
- ❌ **Loading indicators** - Basic only
- ❌ **Empty states** - Basic messages only

#### Data Management
- ❌ **Optimistic updates** - No local state updates
- ❌ **Cache management** - No caching strategy
- ❌ **Offline support** - No offline capabilities
- ❌ **Data refresh** - Manual refresh only

---

## Backend Integration Analysis

### ✅ Currently Integrated

| Frontend Feature | Backend Endpoint | Status |
|------------------|------------------|--------|
| List Machines | `GET /machines` | ✅ Working |
| Create Machine | `POST /machines` | ✅ Working |
| List Work Orders | `GET /workorders` | ✅ Working |
| Create Work Order | `POST /workorders` | ✅ Working |
| List Equipment | `GET /equipment` | ✅ Working |
| Create Equipment | `POST /equipment` | ✅ Working |
| List Inspections | `GET /inspections` | ✅ Working |
| Create Inspection | `POST /inspections` | ✅ Working |
| List Employees | `GET /employees` | ✅ Working |
| Create Employee | `POST /employees` | ✅ Working |
| List Items | `GET /items` | ✅ Working |
| Create Item | `POST /items` | ✅ Working |
| File Upload | `POST /upload/{id}` | ✅ Working |

### ❌ Missing Integration

| Frontend Feature Needed | Backend Endpoint | Status |
|-------------------------|------------------|--------|
| Get Machine by ID | `GET /machines/{id}` | ❌ Not implemented (backend) |
| Update Machine | `PUT /machines/{id}` | ❌ Not implemented (backend) |
| Delete Machine | `DELETE /machines/{id}` | ❌ Not implemented (backend) |
| Dashboard Stats | `GET /dashboard/stats` | ❌ Not implemented (backend) |
| Pagination | Query params `skip`, `limit` | ❌ Not implemented (backend) |
| Filtering | Query params (status, etc.) | ❌ Not implemented (backend) |
| Sorting | Query params `sort_by`, `order` | ❌ Not implemented (backend) |

### Integration Gaps

1. **Frontend expects but backend missing:**
   - Dashboard statistics endpoint
   - GET by ID endpoints
   - UPDATE/DELETE endpoints
   - Pagination support
   - Filtering support

2. **Backend will provide but frontend not ready:**
   - Pagination response format
   - Filter parameters
   - Dashboard statistics format
   - Error response format

3. **Both missing:**
   - Authentication system
   - Error handling improvements
   - Health check UI

---

## Missing Features & Gaps

### Critical Missing Features

#### 1. CRUD Operations (Complete)
**Current**: Only CREATE and LIST
**Needed**: 
- GET by ID for detail views
- UPDATE for editing
- DELETE for removal

**Impact**: Users cannot edit or delete records

---

#### 2. Dashboard API Integration
**Current**: Calculating stats client-side from all data
**Needed**: 
- Call backend `/dashboard/stats` endpoint
- Display server-calculated statistics
- Real-time dashboard updates

**Impact**: Dashboard loads all data unnecessarily, no real-time stats

---

#### 3. Pagination Support
**Current**: Loading all records at once
**Needed**:
- Pagination controls
- Page navigation
- Items per page selection
- Total count display

**Impact**: Performance issues with large datasets, slow loading

---

#### 4. Filtering & Search
**Current**: No filtering
**Needed**:
- Filter by status
- Search by name/id
- Date range filters
- Filter UI components

**Impact**: Difficult to find specific records

---

#### 5. Update/Edit Functionality
**Current**: Only create dialogs
**Needed**:
- Edit dialogs
- Update forms
- Form validation
- Change tracking

**Impact**: Cannot modify existing records

---

#### 6. Delete Functionality
**Current**: No delete
**Needed**:
- Delete buttons
- Confirmation dialogs
- Soft delete support
- Undo functionality

**Impact**: Cannot remove records

---

#### 7. Detail Views
**Current**: Only list views
**Needed**:
- Individual resource detail pages
- Related data display
- Action buttons
- Navigation

**Impact**: Limited information display

---

#### 8. Authentication System
**Current**: No authentication
**Needed**:
- Login screen
- Token storage
- Auth state management
- Protected routes
- Logout functionality

**Impact**: Security vulnerability, no user management

---

#### 9. Error Handling Improvements
**Current**: Basic error handling
**Needed**:
- User-friendly error messages
- Network error handling
- Retry mechanisms
- Error logging
- Error boundary

**Impact**: Poor user experience on errors

---

#### 10. Loading States
**Current**: Basic loading indicators
**Needed**:
- Skeleton loaders
- Progress indicators
- Partial loading states
- Optimistic updates

**Impact**: Poor loading UX

---

## Frontend Development Plan

### Phase 1: Complete CRUD Operations (Week 1-2)

**Aligns with Backend Phase 1**

#### Task 1.1: Add Update/Edit Functionality

**Actions**:
- [ ] Create edit dialogs for all resources
- [ ] Add edit buttons to list views
- [ ] Implement update API calls in ApiService
- [ ] Update AppProvider with update methods
- [ ] Add form validation
- [ ] Handle update errors

**Files to Create/Modify**:
```
lib/
├── services/
│   └── api_service.dart (add update methods)
├── providers/
│   └── app_provider.dart (add update methods)
└── screens/
    ├── work_orders_screen.dart (add edit dialog)
    ├── equipment_screen.dart (add edit dialog)
    ├── inspections_screen.dart (add edit dialog)
    ├── employees_screen.dart (add edit dialog)
    ├── inventory_screen.dart (add edit dialog)
    └── machines_screen.dart (add edit dialog)
```

**Implementation Example**:
```dart
// api_service.dart
Future<WorkOrder> updateWorkOrder(int id, WorkOrder workOrder) async {
  try {
    final response = await http.put(
      Uri.parse('${ApiConfig.workOrders}/$id'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(workOrder.toJson()),
    ).timeout(ApiConfig.connectionTimeout);

    if (response.statusCode == 200) {
      return WorkOrder.fromJson(json.decode(response.body) as Map<String, dynamic>);
    } else {
      throw Exception('Failed to update: ${response.statusCode}');
    }
  } catch (e) {
    throw Exception('Network error: $e');
  }
}

// app_provider.dart
Future<void> updateWorkOrder(int id, WorkOrder workOrder) async {
  try {
    _isLoading = true;
    notifyListeners();

    final updated = await _apiService.updateWorkOrder(id, workOrder);
    final index = _workOrders.indexWhere((wo) => wo.id == id);
    if (index != -1) {
      _workOrders[index] = updated;
    }
    
    _isLoading = false;
    notifyListeners();
  } catch (e) {
    _errorMessage = e.toString();
    _isLoading = false;
    notifyListeners();
    rethrow;
  }
}
```

---

#### Task 1.2: Add Delete Functionality

**Actions**:
- [ ] Add delete methods to ApiService
- [ ] Add delete methods to AppProvider
- [ ] Create confirmation dialogs
- [ ] Add delete buttons to list views
- [ ] Handle delete errors
- [ ] Add undo functionality (optional)

**Implementation Example**:
```dart
// api_service.dart
Future<void> deleteWorkOrder(int id) async {
  try {
    final response = await http.delete(
      Uri.parse('${ApiConfig.workOrders}/$id'),
    ).timeout(ApiConfig.connectionTimeout);

    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception('Failed to delete: ${response.statusCode}');
    }
  } catch (e) {
    throw Exception('Network error: $e');
  }
}

// Confirmation dialog
Future<bool?> _showDeleteDialog(BuildContext context, String title) {
  return showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text('Delete $title'),
      content: Text('Are you sure you want to delete this $title? This action cannot be undone.'),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () => Navigator.pop(context, true),
          style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
          child: const Text('Delete'),
        ),
      ],
    ),
  );
}
```

---

#### Task 1.3: Add GET by ID & Detail Views

**Actions**:
- [ ] Add GET by ID methods to ApiService
- [ ] Create detail view screens
- [ ] Add navigation to detail views
- [ ] Display full resource information
- [ ] Add action buttons (edit/delete)

**Files to Create**:
```
lib/
└── screens/
    ├── work_order_detail_screen.dart
    ├── equipment_detail_screen.dart
    ├── inspection_detail_screen.dart
    ├── employee_detail_screen.dart
    ├── item_detail_screen.dart
    └── machine_detail_screen.dart
```

---

### Phase 2: Dashboard API & Query Features (Week 3-4)

**Aligns with Backend Phase 2**

#### Task 2.1: Integrate Dashboard API

**Actions**:
- [ ] Create dashboard API service method
- [ ] Create dashboard statistics model
- [ ] Update dashboard screen to use API
- [ ] Add loading states
- [ ] Handle errors gracefully
- [ ] Add refresh functionality

**Implementation**:
```dart
// models/dashboard_stats.dart
class DashboardStats {
  final WorkOrderStats workOrders;
  final EquipmentStats equipment;
  final InspectionStats inspections;
  final InventoryStats inventory;
  final EmployeeStats employees;

  DashboardStats({
    required this.workOrders,
    required this.equipment,
    required this.inspections,
    required this.inventory,
    required this.employees,
  });

  factory DashboardStats.fromJson(Map<String, dynamic> json) {
    return DashboardStats(
      workOrders: WorkOrderStats.fromJson(json['work_orders']),
      equipment: EquipmentStats.fromJson(json['equipment']),
      inspections: InspectionStats.fromJson(json['inspections']),
      inventory: InventoryStats.fromJson(json['inventory']),
      employees: EmployeeStats.fromJson(json['employees']),
    );
  }
}

// api_service.dart
Future<DashboardStats> getDashboardStats() async {
  try {
    final response = await http.get(
      Uri.parse('${ApiConfig.baseUrl}/dashboard/stats'),
    ).timeout(ApiConfig.connectionTimeout);

    if (response.statusCode == 200) {
      return DashboardStats.fromJson(
        json.decode(response.body) as Map<String, dynamic>
      );
    } else {
      throw Exception('Failed to load dashboard stats: ${response.statusCode}');
    }
  } catch (e) {
    throw Exception('Network error: $e');
  }
}
```

---

#### Task 2.2: Implement Pagination

**Actions**:
- [ ] Create pagination widget
- [ ] Update API service to support pagination params
- [ ] Update providers to handle paginated data
- [ ] Add pagination controls to all list screens
- [ ] Display total count
- [ ] Add items per page selector

**Implementation**:
```dart
// widgets/pagination_widget.dart
class PaginationWidget extends StatelessWidget {
  final int currentPage;
  final int totalPages;
  final int totalItems;
  final int itemsPerPage;
  final Function(int) onPageChanged;
  final Function(int) onItemsPerPageChanged;

  const PaginationWidget({
    required this.currentPage,
    required this.totalPages,
    required this.totalItems,
    required this.itemsPerPage,
    required this.onPageChanged,
    required this.onItemsPerPageChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text('Showing ${(currentPage - 1) * itemsPerPage + 1}-${currentPage * itemsPerPage} of $totalItems'),
        Row(
          children: [
            IconButton(
              icon: const Icon(Icons.chevron_left),
              onPressed: currentPage > 1 
                ? () => onPageChanged(currentPage - 1) 
                : null,
            ),
            Text('Page $currentPage of $totalPages'),
            IconButton(
              icon: const Icon(Icons.chevron_right),
              onPressed: currentPage < totalPages 
                ? () => onPageChanged(currentPage + 1) 
                : null,
            ),
          ],
        ),
      ],
    );
  }
}
```

---

#### Task 2.3: Implement Filtering & Search

**Actions**:
- [ ] Create filter widget component
- [ ] Add search bars to list screens
- [ ] Update API service to support filter params
- [ ] Update providers with filter methods
- [ ] Add filter UI for each resource type
- [ ] Add clear filters functionality

**Implementation**:
```dart
// widgets/filter_widget.dart
class FilterWidget extends StatefulWidget {
  final Function(Map<String, dynamic>) onFilterChanged;
  
  const FilterWidget({required this.onFilterChanged});

  @override
  State<FilterWidget> createState() => _FilterWidgetState();
}

class _FilterWidgetState extends State<FilterWidget> {
  String? statusFilter;
  String? searchQuery;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                decoration: const InputDecoration(
                  labelText: 'Search',
                  prefixIcon: Icon(Icons.search),
                ),
                onChanged: (value) {
                  setState(() {
                    searchQuery = value.isEmpty ? null : value;
                  });
                  _applyFilters();
                },
              ),
            ),
            const SizedBox(width: 16),
            DropdownButton<String>(
              value: statusFilter,
              hint: const Text('Filter by Status'),
              items: ['Pending', 'In Progress', 'Completed']
                  .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                  .toList(),
              onChanged: (value) {
                setState(() {
                  statusFilter = value;
                });
                _applyFilters();
              },
            ),
            if (statusFilter != null || searchQuery != null)
              IconButton(
                icon: const Icon(Icons.clear),
                onPressed: () {
                  setState(() {
                    statusFilter = null;
                    searchQuery = null;
                  });
                  _applyFilters();
                },
              ),
          ],
        ),
      ),
    );
  }

  void _applyFilters() {
    widget.onFilterChanged({
      'status': statusFilter,
      'search': searchQuery,
    });
  }
}
```

---

### Phase 3: Authentication & Security (Week 5-6)

**Aligns with Backend Phase 3**

#### Task 3.1: Implement Firebase Authentication UI

**Actions**:
- [ ] Install Firebase packages: `firebase_core`, `firebase_auth`
- [ ] Initialize Firebase in main.dart
- [ ] Create login screen with email/password
- [ ] Create Firebase auth service
- [ ] Create auth provider with Firebase integration
- [ ] Add protected route wrapper
- [ ] Add logout functionality
- [ ] Handle authentication state changes

**Files to Create**:
```
lib/
├── config/
│   └── firebase_config.dart     # Firebase configuration
├── screens/
│   └── login_screen.dart        # Login/signup screen
├── services/
│   └── auth_service.dart        # Firebase auth service
├── providers/
│   └── auth_provider.dart       # Auth state management
└── widgets/
    └── auth_wrapper.dart        # Protected route wrapper
```

**Detailed Implementation**: See `07_Authentication_System_Firebase.md` → Frontend Implementation

---

#### Task 3.2: Add Firebase Token Management

**Actions**:
- [ ] Get Firebase ID tokens from Firebase Auth
- [ ] Add Firebase ID token to API request headers
- [ ] Handle token expiration (Firebase handles refresh automatically)
- [ ] Store tokens securely (Firebase SDK manages this)
- [ ] Add auth interceptors to API service

**Implementation Notes**:
- Firebase SDK automatically refreshes tokens
- Use `FirebaseAuth.instance.currentUser?.getIdToken()` to get tokens
- Add `Authorization: Bearer <token>` header to API requests

**Detailed Implementation**: See `07_Authentication_System_Firebase.md` → Frontend Implementation

---

### Phase 4: Error Handling & UX Improvements (Week 7-8)

**Aligns with Backend Phase 4**

#### Task 4.1: Improve Error Handling

**Actions**:
- [ ] Create error handling utilities
- [ ] Add user-friendly error messages
- [ ] Implement retry mechanisms
- [ ] Add error logging
- [ ] Create error display widgets

---

#### Task 4.2: Enhance User Experience

**Actions**:
- [ ] Add skeleton loaders
- [ ] Improve loading states
- [ ] Add empty state illustrations
- [ ] Implement optimistic updates
- [ ] Add success notifications
- [ ] Improve form validation feedback

---

## Implementation Tasks

### Priority 1: Critical (Weeks 1-2)

- [ ] **Task 1.1**: Add UPDATE functionality (edit dialogs)
- [ ] **Task 1.2**: Add DELETE functionality
- [ ] **Task 1.3**: Add GET by ID & detail views
- [ ] Update all 7 screens with edit/delete

**Dependencies**: Backend must implement UPDATE/DELETE endpoints first

---

### Priority 2: High (Weeks 3-4)

- [ ] **Task 2.1**: Integrate Dashboard API
- [ ] **Task 2.2**: Implement Pagination
- [ ] **Task 2.3**: Implement Filtering & Search

**Dependencies**: Backend must implement dashboard endpoints and pagination first

---

### Priority 3: Medium (Weeks 5-6)

- [ ] **Task 3.1**: Implement Authentication UI
- [ ] **Task 3.2**: Add Token Management

**Dependencies**: Backend must implement authentication first

---

### Priority 4: Low (Weeks 7-8)

- [ ] **Task 4.1**: Improve Error Handling
- [ ] **Task 4.2**: Enhance User Experience

**Dependencies**: None

---

## File Structure (Target)

```
improvementworkshop/
├── lib/
│   ├── main.dart
│   ├── config/
│   │   └── api_config.dart
│   ├── models/
│   │   ├── dashboard_stats.dart (NEW)
│   │   └── (existing models)
│   ├── services/
│   │   ├── api_service.dart (UPDATE - add update/delete/getById)
│   │   └── auth_service.dart (NEW)
│   ├── providers/
│   │   ├── app_provider.dart (UPDATE - add update/delete methods)
│   │   └── auth_provider.dart (NEW)
│   ├── screens/
│   │   ├── login_screen.dart (NEW)
│   │   ├── (existing screens - UPDATE with edit/delete)
│   │   └── detail/
│   │       ├── work_order_detail_screen.dart (NEW)
│   │       ├── equipment_detail_screen.dart (NEW)
│   │       └── (other detail screens)
│   ├── widgets/
│   │   ├── pagination_widget.dart (NEW)
│   │   ├── filter_widget.dart (NEW)
│   │   ├── protected_route.dart (NEW)
│   │   └── (existing widgets)
│   └── utils/
│       ├── error_handler.dart (NEW)
│       └── validators.dart (NEW)
```

---

## Dependencies to Add

```yaml
dependencies:
  # Existing dependencies...
  
  # Authentication & Security
  shared_preferences: ^2.2.2  # Token storage
  flutter_secure_storage: ^9.0.0  # Secure token storage
  
  # UI Enhancements
  shimmer: ^3.0.0  # Skeleton loaders
  fluttertoast: ^8.2.4  # Toast notifications
  
  # Utilities
  connectivity_plus: ^5.0.2  # Network connectivity check
```

---

## Success Criteria

### Phase 1 Success
- ✅ All resources can be updated
- ✅ All resources can be deleted
- ✅ Detail views available for all resources
- ✅ Edit dialogs working

### Phase 2 Success
- ✅ Dashboard using backend API
- ✅ Pagination working on all lists
- ✅ Filtering working on all lists
- ✅ Search functionality working

### Phase 3 Success
- ✅ Login screen functional
- ✅ Protected routes working
- ✅ Token management working
- ✅ Logout functional

### Phase 4 Success
- ✅ Error handling comprehensive
- ✅ UX improvements implemented
- ✅ Loading states improved
- ✅ User feedback enhanced

---

## Timeline Summary

| Phase | Duration | Focus | Aligns with Backend |
|-------|----------|-------|---------------------|
| Phase 1 | Weeks 1-2 | Complete CRUD | Backend Phase 1 |
| Phase 2 | Weeks 3-4 | Dashboard & Query Features | Backend Phase 2 |
| Phase 3 | Weeks 5-6 | Authentication | Backend Phase 3 |
| Phase 4 | Weeks 7-8 | Error Handling & UX | Backend Phase 4 |

**Total Timeline**: 8 weeks (parallel with backend development)

---

## Integration Checklist

### Backend Dependencies

**Frontend Phase 1 requires:**
- [ ] Backend: GET by ID endpoints implemented
- [ ] Backend: UPDATE endpoints implemented
- [ ] Backend: DELETE endpoints implemented

**Frontend Phase 2 requires:**
- [ ] Backend: Dashboard stats endpoint implemented
- [ ] Backend: Pagination implemented
- [ ] Backend: Filtering implemented

**Frontend Phase 3 requires:**
- [ ] Backend: Authentication endpoints implemented
- [ ] Backend: JWT token generation working

**Frontend Phase 4:**
- [ ] No backend dependencies

---

## Next Steps

1. **Review Backend Plan**: Ensure backend endpoints will be ready
2. **Start Phase 1**: Implement UPDATE/DELETE once backend is ready
3. **Coordinate**: Work in parallel with backend team
4. **Test Integration**: Test each feature as backend implements it

---

**Document Version**: 1.0  
**Created**: December 2024  
**Status**: Ready for Implementation

---

## Authentication Implementation

**Important**: This plan uses **Firebase Authentication** for user management.

For detailed Firebase Authentication setup and implementation guide, see:
- **`07_Authentication_System_Firebase.md`** - Complete Firebase auth guide

### Key Features:

1. **Firebase Auth SDK**: Flutter uses `firebase_auth` package
2. **Automatic Token Management**: Firebase handles token refresh
3. **Multiple Sign-in Methods**: Email/Password, Google (optional)
4. **Secure Token Storage**: Firebase SDK manages token storage
5. **Backend Integration**: Send Firebase ID tokens to backend for verification

### Phase 3 Authentication Tasks Reference:

- Firebase Setup: See `07_Authentication_System_Firebase.md` → Firebase Setup
- Frontend Implementation: See `07_Authentication_System_Firebase.md` → Frontend Implementation
- Backend Integration: Backend verifies Firebase tokens (see backend plan)

---

*This plan is designed to work in parallel with the backend implementation plan. Frontend development should align with backend feature delivery.*

