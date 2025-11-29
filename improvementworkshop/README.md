# Welding Workshop Management - Flutter Frontend

Professional web application for managing welding workshop operations, built with Flutter and deployed on Firebase Hosting.

## 🚀 Features

- **Dashboard**: Real-time analytics with interactive charts and statistics
- **Work Orders**: Create and track welding work orders with status management
- **Equipment Management**: Monitor equipment status and maintenance schedules
- **Quality Inspections**: Record and track QC inspections with pass/fail results
- **Employee Management**: Manage workforce and track certifications
- **Inventory Control**: Track materials and supplies with low-stock alerts
- **Machine Configuration**: Configure machines and import templates
- **Excel Import**: Upload Excel files for bulk data import
- **Responsive Design**: Adapts to desktop, tablet, and mobile screens

## 🛠 Tech Stack

- **Framework**: Flutter 3.x (Web)
- **State Management**: Provider
- **HTTP Client**: http package
- **Charts**: FL Chart
- **File Handling**: file_picker package
- **Date Formatting**: intl package
- **Backend**: FastAPI on Render.com
- **Hosting**: Firebase Hosting

## 📋 Prerequisites

Before you begin, ensure you have:

- Flutter SDK (3.0 or higher)
- Dart SDK
- Node.js and npm (for Firebase CLI)
- Firebase account (project: `weldingworkshop-f4697`)
- Git
- Code editor (VS Code recommended)

## 🔧 Installation

### 1. Install Flutter

```bash
# Download Flutter from https://flutter.dev/docs/get-started/install
# Add Flutter to PATH

# Verify installation
flutter --version
flutter doctor
```

### 2. Create Flutter Project

```bash
# Create new Flutter project
flutter create welding_workshop_app
cd welding_workshop_app

# Enable web support
flutter config --enable-web
```

### 3. Update pubspec.yaml

Replace the content of `pubspec.yaml` with:

```yaml
name: welding_workshop_app
description: Professional Welding Workshop Management System
publish_to: 'none'
version: 1.0.0+1

environment:
  sdk: '>=3.0.0 <4.0.0'

dependencies:
  flutter:
    sdk: flutter
  provider: ^6.1.1
  http: ^1.1.0
  file_picker: ^6.1.1
  fl_chart: ^0.65.0
  intl: ^0.18.1
  cupertino_icons: ^1.0.2

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^2.0.0

flutter:
  uses-material-design: true
```

### 4. Install Dependencies

```bash
flutter pub get
```

### 5. Create Project Structure

Create the complete folder structure:

```bash
# Create directories
mkdir -p lib/config
mkdir -p lib/models
mkdir -p lib/services
mkdir -p lib/providers
mkdir -p lib/screens
mkdir -p lib/widgets
```

Complete structure:

```
welding_workshop_app/
├── lib/
│   ├── main.dart                          # App entry point
│   ├── config/
│   │   └── api_config.dart                # API base URL
│   ├── models/
│   │   ├── work_order.dart                # WorkOrder model
│   │   ├── equipment.dart                 # Equipment model
│   │   ├── inspection.dart                # Inspection model
│   │   ├── employee.dart                  # Employee model
│   │   ├── item.dart                      # Inventory Item model
│   │   ├── machine.dart                   # Machine model
│   │   └── template.dart                  # Template model
│   ├── services/
│   │   └── api_service.dart               # HTTP API calls
│   ├── providers/
│   │   └── app_provider.dart              # State management
│   ├── screens/
│   │   ├── dashboard_screen.dart          # Dashboard with charts
│   │   ├── work_orders_screen.dart        # Work orders management
│   │   ├── equipment_screen.dart          # Equipment tracking
│   │   ├── inspections_screen.dart        # Quality inspections
│   │   ├── employees_screen.dart          # Employee management
│   │   ├── inventory_screen.dart          # Inventory control
│   │   └── machines_screen.dart           # Machine & templates
│   └── widgets/
│       ├── custom_card.dart               # Reusable card widgets
│       ├── data_table.dart                # Table components
│       └── chart_widget.dart              # Chart components
├── web/
│   └── index.html                         # Auto-generated
├── .firebaserc                            # Firebase project config
├── firebase.json                          # Firebase hosting config
├── pubspec.yaml                           # Dependencies
└── README.md                              # This file
```

### 6. Copy Code Files

Copy all the code from the provided artifacts into the corresponding files:

**Core Files:**
1. Copy `main.dart` content → `lib/main.dart`
2. Copy `api_config.dart` content → `lib/config/api_config.dart`

**Model Files (7 files):**
3. Copy `work_order.dart` → `lib/models/work_order.dart`
4. Copy `equipment.dart` → `lib/models/equipment.dart`
5. Copy `inspection.dart` → `lib/models/inspection.dart`
6. Copy `employee.dart` → `lib/models/employee.dart`
7. Copy `item.dart` → `lib/models/item.dart`
8. Copy `machine.dart` → `lib/models/machine.dart`
9. Copy `template.dart` → `lib/models/template.dart`

**Service & Provider:**
10. Copy `api_service.dart` → `lib/services/api_service.dart`
11. Copy `app_provider.dart` → `lib/providers/app_provider.dart`

**Screen Files (7 files):**
12. Copy `dashboard_screen.dart` → `lib/screens/dashboard_screen.dart`
13. Copy `work_orders_screen.dart` → `lib/screens/work_orders_screen.dart`
14. Copy `equipment_screen.dart` → `lib/screens/equipment_screen.dart`
15. Copy `inspections_screen.dart` → `lib/screens/inspections_screen.dart`
16. Copy `employees_screen.dart` → `lib/screens/employees_screen.dart`
17. Copy `inventory_screen.dart` → `lib/screens/inventory_screen.dart`
18. Copy `machines_screen.dart` → `lib/screens/machines_screen.dart`

**Widget Files (3 files):**
19. Copy `custom_card.dart` → `lib/widgets/custom_card.dart`
20. Copy `data_table.dart` → `lib/widgets/data_table.dart`
21. Copy `chart_widget.dart` → `lib/widgets/chart_widget.dart`

**Firebase Configuration:**
22. Copy `firebase.json` → project root
23. Copy `.firebaserc` → project root

### 7. Configure Backend URL

Verify the backend URL in `lib/config/api_config.dart`:

```dart
class ApiConfig {
  // Production backend on Render.com
  static const String baseUrl = 'https://welding-backend-v1-0.onrender.com';
  
  // For local development, use:
  // static const String baseUrl = 'http://localhost:8000';
}
```

### 8. Verify Installation

```bash
# Check for any errors
flutter analyze

# Run the app locally
flutter run -d chrome
```

## 🧪 Testing Locally

### Run on Chrome

```bash
flutter run -d chrome
```

### Run on Edge

```bash
flutter run -d edge
```

### Hot Reload

While the app is running, press `r` in the terminal to hot reload changes.

### Build for Production

```bash
flutter build web --release
```

The built files will be in `build/web/` directory.

## 🔥 Firebase Deployment

### 1. Install Firebase CLI

```bash
npm install -g firebase-tools
```

### 2. Login to Firebase

```bash
firebase login
```

### 3. Initialize Firebase Hosting

```bash
firebase init hosting
```

When prompted:
- **Select project**: Choose existing project `weldingworkshop-f4697`
- **Public directory**: Enter `build/web`
- **Configure as SPA**: Select `Yes`
- **Set up automatic builds**: Select `No`
- **Overwrite index.html**: Select `No`

### 4. Verify Firebase Configuration

Ensure `firebase.json` contains:

```json
{
  "hosting": {
    "public": "build/web",
    "ignore": [
      "firebase.json",
      "**/.*",
      "**/node_modules/**"
    ],
    "rewrites": [
      {
        "source": "**",
        "destination": "/index.html"
      }
    ],
    "headers": [
      {
        "source": "**",
        "headers": [
          {
            "key": "Cache-Control",
            "value": "no-cache, no-store, must-revalidate"
          }
        ]
      },
      {
        "source": "**/*.@(jpg|jpeg|gif|png|svg|webp|js|css|eot|otf|ttf|ttc|woff|woff2|font.css)",
        "headers": [
          {
            "key": "Cache-Control",
            "value": "max-age=604800"
          }
        ]
      }
    ]
  }
}
```

Ensure `.firebaserc` contains:

```json
{
  "projects": {
    "default": "weldingworkshop-f4697"
  }
}
```

### 5. Build and Deploy

```bash
# Build the Flutter web app
flutter build web --release

# Deploy to Firebase
firebase deploy
```

### 6. Access Your App

Your app will be live at:
```
https://weldingworkshop-f4697.web.app/
```

## 📱 Usage Guide

### Dashboard
- **Overview**: View real-time statistics for work orders, equipment, inspections, and employees
- **Charts**: Interactive pie charts showing work order status and inspection results
- **Low Stock Alerts**: Table displaying inventory items below reorder level
- **Refresh**: Click refresh icon to reload data

### Work Orders
- **Create**: Click "New Order" button to create a work order
- **Fields**: Order ID, Client, Description, Status, Due Date, Assigned Welder
- **Status Options**: Pending, In Progress, Completed
- **View**: All orders displayed in a sortable table
- **Refresh**: Reload work orders from backend

### Equipment
- **Add Equipment**: Click "Add Equipment" to register new machinery
- **Grid View**: Equipment cards showing name, status, and last service date
- **Status Types**: Operational (green), Maintenance (orange), Out of Service (red)
- **Track Service**: Monitor last service date for each equipment

### Inspections
- **Record**: Click "New Inspection" to log quality control results
- **Link Orders**: Associate inspections with work order IDs
- **Results**: Pass/Fail with optional defect type documentation
- **Inspector**: Track who performed each inspection
- **View History**: Complete inspection table with color-coded results

### Employees
- **Add Employee**: Register new team members with ID and name
- **Roles**: Assign job roles (Welder, Inspector, Manager, etc.)
- **Certifications**: Track certification expiry dates
- **List View**: Employee cards with contact information

### Inventory
- **Add Items**: Register inventory items with ID and name
- **Quantity Tracking**: Monitor current stock levels
- **Reorder Levels**: Set minimum stock thresholds
- **Low Stock Alerts**: Automatic alerts when items need reordering
- **Units**: Track in various units (kg, pcs, meters, etc.)

### Machines & Templates
- **Add Machine**: Configure welding machines with unique codes
- **Templates**: Create data import templates for Excel files
- **Mapping**: Map Excel columns to database fields
- **Upload**: Import bulk data via Excel files

## 🔄 Continuous Deployment

### Update and Redeploy

```bash
# 1. Make your code changes

# 2. Test locally
flutter run -d chrome

# 3. Build for production
flutter build web --release

# 4. Deploy to Firebase
firebase deploy

# 5. Verify deployment
# Visit: https://weldingworkshop-f4697.web.app/
```

### View Deployment History

```bash
firebase hosting:releases
```

### Rollback to Previous Version

```bash
firebase hosting:rollback
```

## 🐛 Troubleshooting

### CORS Issues

If you encounter CORS errors when calling the backend:

**Solution**: Ensure your FastAPI backend has correct CORS configuration:

```python
origins = [
    "http://localhost:5000",
    "https://weldingworkshop-f4697.web.app"
]
app.add_middleware(
    CORSMiddleware,
    allow_origins=origins,
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)
```

### Import Errors

**Issue**: `Error: Cannot find module 'package:...'`

**Solution**: 
```bash
flutter clean
flutter pub get
flutter run -d chrome
```

### Build Errors

**Issue**: Build fails with errors

**Solution**:
```bash
# Clean build cache
flutter clean

# Get dependencies
flutter pub get

# Rebuild
flutter build web --release
```

### Firebase Deployment Fails

**Issue**: `Error: HTTP Error: 403, Project not found`

**Solution**:
```bash
# Re-authenticate
firebase logout
firebase login

# Verify project
firebase projects:list
firebase use weldingworkshop-f4697

# Try deploying again
firebase deploy
```

### Provider Not Found

**Issue**: `Error: Could not find the correct Provider<AppProvider>`

**Solution**: Ensure `main.dart` wraps the app with `ChangeNotifierProvider`:
```dart
void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => AppProvider(),
      child: const WeldingWorkshopApp(),
    ),
  );
}
```

### API Connection Fails

**Issue**: Network errors or timeouts

**Solution**:
1. Check `lib/config/api_config.dart` has correct backend URL
2. Verify backend is running on Render.com
3. Check browser console for specific error messages
4. Test backend endpoint directly in browser or Postman

## 📊 API Endpoints

The app connects to these backend endpoints:

| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/machines` | List all machines |
| POST | `/machines` | Create new machine |
| GET | `/templates` | List all templates |
| POST | `/templates` | Create new template |
| GET | `/workorders` | List all work orders |
| POST | `/workorders` | Create new work order |
| GET | `/equipment` | List all equipment |
| POST | `/equipment` | Create new equipment |
| GET | `/inspections` | List all inspections |
| POST | `/inspections` | Create new inspection |
| GET | `/employees` | List all employees |
| POST | `/employees` | Create new employee |
| GET | `/items` | List all inventory items |
| POST | `/items` | Create new item |
| POST | `/upload/{template_id}` | Upload Excel file |
| POST | `/schedule/import/{template_id}` | Schedule import job |

**Base URL**: `https://welding-backend-v1-0.onrender.com`

## 🔒 Security Notes

- Never commit `.env` files or API keys to version control
- Use environment variables for sensitive data in production
- Implement user authentication (Firebase Auth recommended)
- Enable Firebase Security Rules for Firestore/Storage
- Use HTTPS for all API calls (already configured)
- Validate all user inputs on both frontend and backend
- Implement rate limiting on backend APIs
- Regular security audits and dependency updates

## 📝 Development Workflow

1. **Create Feature Branch**
   ```bash
   git checkout -b feature/new-feature
   ```

2. **Make Changes**
   - Edit code files
   - Follow Dart style guide

3. **Test Locally**
   ```bash
   flutter run -d chrome
   ```

4. **Run Tests**
   ```bash
   flutter test
   ```

5. **Build for Production**
   ```bash
   flutter build web --release
   ```

6. **Deploy**
   ```bash
   firebase deploy
   ```

7. **Verify**
   - Visit https://weldingworkshop-f4697.web.app/
   - Test all features

## 🎯 Future Enhancements

### Planned Features
- [ ] **User Authentication**: Firebase Auth integration with role-based access
- [ ] **Real-time Updates**: WebSocket connection for live data sync
- [ ] **Advanced Analytics**: Historical trends, predictive analytics
- [ ] **PDF Reports**: Generate and download reports
- [ ] **Mobile Apps**: Native iOS and Android applications
- [ ] **Offline Mode**: Local data caching with sync
- [ ] **Multi-language**: i18n support for multiple languages
- [ ] **Dark Mode**: Theme switching capability
- [ ] **Notifications**: Push notifications for important events
- [ ] **Export Data**: CSV/Excel export functionality
- [ ] **Advanced Search**: Full-text search across all entities
- [ ] **Barcode Scanning**: QR code support for equipment tracking

### Technical Improvements
- [ ] Unit tests for all models and services
- [ ] Widget tests for UI components
- [ ] Integration tests for critical workflows
- [ ] CI/CD pipeline with GitHub Actions
- [ ] Error logging and monitoring (Sentry)
- [ ] Performance optimization
- [ ] Accessibility improvements (WCAG compliance)

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

### Coding Standards
- Follow [Dart Style Guide](https://dart.dev/guides/language/effective-dart/style)
- Use meaningful variable and function names
- Comment complex logic
- Write unit tests for new features
- Update documentation

## 📄 License

This project is proprietary software for welding workshop management.

## 📞 Support

### Backend Issues
- **Backend URL**: https://welding-backend-v1-0.onrender.com
- **Check Status**: Render.com dashboard
- **View Logs**: Render.com logs section

### Frontend Issues
- **Check Console**: Browser developer tools (F12)
- **Firebase Status**: Firebase console
- **Review Config**: `lib/config/api_config.dart`

### Common Questions

**Q: How do I change the backend URL?**  
A: Edit `lib/config/api_config.dart` and update the `baseUrl` constant.

**Q: Can I run this on mobile?**  
A: Yes, but you'll need to build mobile apps separately. Current version is optimized for web.

**Q: How do I add new features?**  
A: Create new screens in `lib/screens/`, add routes in `main.dart`, and update navigation.

**Q: Where are uploaded files stored?**  
A: Files are uploaded to the backend which stores them on Render.com or AWS S3 (check backend config).

## 🏗 Architecture

### State Management
- **Provider Pattern**: Reactive state management
- **AppProvider**: Central state container
- **Consumer Widgets**: UI updates on state changes

### Code Organization
```
lib/
├── config/         # Configuration files
├── models/         # Data models
├── services/       # API and business logic
├── providers/      # State management
├── screens/        # UI screens
└── widgets/        # Reusable components
```

### Data Flow
```
User Action → Widget → Provider → Service → API → Backend
                ↓         ↓
              State    Update UI
```

---

## ✅ Quick Start Checklist

- [ ] Flutter SDK installed and verified
- [ ] Project created with `flutter create`
- [ ] All 25 files copied to correct locations
- [ ] Dependencies installed with `flutter pub get`
- [ ] Backend URL configured correctly
- [ ] App runs successfully in Chrome
- [ ] Firebase CLI installed
- [ ] Firebase project initialized
- [ ] Production build successful
- [ ] App deployed to Firebase
- [ ] Live URL accessible and working

---

**Built with ❤️ using Flutter**

**Version**: 1.0.0  
**Last Updated**: November 2024  
**Maintained By**: Workshop Management Team

For questions or support, please check the troubleshooting section or contact the development team.