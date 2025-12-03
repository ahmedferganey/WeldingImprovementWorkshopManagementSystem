# Welding Workshop Management System

**Full-Stack Web Application for Welding Workshop Operations**

[![FastAPI](https://img.shields.io/badge/FastAPI-0.100.0-009688?logo=fastapi)](https://fastapi.tiangolo.com/)
[![Flutter](https://img.shields.io/badge/Flutter-3.x-02569B?logo=flutter)](https://flutter.dev/)
[![MySQL](https://img.shields.io/badge/MySQL-8.0-4479A1?logo=mysql)](https://www.mysql.com/)
[![Docker](https://img.shields.io/badge/Docker-Ready-2496ED?logo=docker)](https://www.docker.com/)

---

## 📋 Table of Contents

- [Overview](#-overview)
- [Architecture](#-architecture)
- [Features](#-features)
- [Tech Stack](#-tech-stack)
- [Prerequisites](#-prerequisites)
- [Backend Setup](#-backend-setup)
- [Frontend Setup](#-frontend-setup)
- [Deployment](#-deployment)
- [API Documentation](#-api-documentation)
- [Project Structure](#-project-structure)
- [Configuration](#-configuration)
- [Troubleshooting](#-troubleshooting)
- [Contributing](#-contributing)

---

## 🎯 Overview

A comprehensive workshop management system designed for welding operations, featuring real-time analytics, work order tracking, equipment management, quality inspections, and inventory control. The system consists of a FastAPI backend deployed on Render.com with AWS RDS MySQL database, and a Flutter web frontend hosted on Firebase.

**Live URLs:**
- **Backend API**: https://welding-backend-v1-0.onrender.com
- **Frontend App**: https://weldingworkshop-f4697.web.app
- **Firebase Project**: weldingworkshop-f4697

---

## 🏗 Architecture

```
┌─────────────────┐
│  Flutter Web    │
│  (Firebase)     │
└────────┬────────┘
         │ HTTPS/REST
         ▼
┌─────────────────┐
│   FastAPI       │
│  (Render.com)   │
└────────┬────────┘
         │
    ┌────┴────┐
    │         │
    ▼         ▼
┌────────┐ ┌────────┐
│AWS RDS │ │AWS S3  │
│MySQL   │ │Storage │
└────────┘ └────────┘
```

**Data Flow:**
- User interacts with Flutter Web UI
- Provider state management handles UI updates
- API Service makes REST calls to FastAPI backend
- FastAPI processes requests with async SQLAlchemy
- MySQL stores relational data
- S3 stores uploaded Excel files
- APScheduler handles daily import jobs

---

## ✨ Features

### Core Functionality
- **Dashboard Analytics**: Real-time statistics with interactive charts
- **Work Order Management**: Create, track, and manage welding orders
- **Equipment Tracking**: Monitor equipment status and maintenance schedules
- **Quality Inspections**: Record QC inspections with pass/fail results
- **Employee Management**: Track workforce and certifications
- **Inventory Control**: Monitor materials with low-stock alerts
- **Machine Configuration**: Configure machines and data templates
- **Excel Import**: Bulk data import from Excel files
- **Scheduled Imports**: Automated daily data imports

### Technical Features
- **Async Database Operations**: High-performance async SQLAlchemy
- **RESTful API**: Fully documented FastAPI endpoints
- **Responsive Design**: Works on desktop, tablet, and mobile
- **State Management**: Provider pattern for reactive UI
- **File Upload**: Support for Excel file processing
- **CORS Enabled**: Secure cross-origin requests
- **Docker Ready**: Containerized deployment
- **Cloud Storage**: AWS S3 integration for files

---

## 🛠 Tech Stack

### Backend
- **Framework**: FastAPI 0.100.0
- **Database**: MySQL 8.0 (AWS RDS)
- **ORM**: SQLAlchemy 2.0.22 (async)
- **Task Scheduler**: APScheduler 3.10.1
- **Data Processing**: Pandas 2.2.3, OpenPyXL 3.1.2
- **Storage**: AWS S3
- **Server**: Uvicorn (ASGI)
- **Containerization**: Docker

### Frontend
- **Framework**: Flutter 3.x (Web)
- **State Management**: Provider 6.1.1
- **HTTP Client**: http 1.1.0
- **Charts**: FL Chart 0.65.0
- **File Upload**: file_picker 6.1.1
- **Date Formatting**: intl 0.18.1
- **Hosting**: Firebase Hosting

### Infrastructure
- **Backend Hosting**: Render.com (Free Tier)
- **Database**: AWS RDS MySQL
- **File Storage**: AWS S3
- **Frontend Hosting**: Firebase Hosting
- **CI/CD**: Git-based auto-deploy

---

## 📦 Prerequisites

### Required Software
- **Flutter SDK**: 3.0 or higher
- **Dart SDK**: Included with Flutter
- **Node.js**: v14 or higher
- **npm**: v6 or higher
- **Python**: 3.11
- **Docker**: Latest version
- **Git**: Latest version

### Required Accounts
- **Firebase Account** (Free)
- **Render.com Account** (Free Tier)
- **AWS Account** (RDS + S3)
- **DockerHub Account** (Optional, for private images)

### Install Flutter
```bash
# Download from https://flutter.dev/docs/get-started/install
# Add to PATH

# Verify installation
flutter --version
flutter doctor

# Enable web support
flutter config --enable-web
```

### Install Firebase CLI
```bash
npm install -g firebase-tools
firebase login
```

### Install Docker
```bash
# Download from https://www.docker.com/get-started
# Verify installation
docker --version
docker-compose --version
```

---

## 🔧 Backend Setup

### 1. Clone Repository
```bash
git clone <your-repo-url>
cd backend
```

### 2. Create Virtual Environment
```bash
python -m venv venv

# Linux/Mac
source venv/bin/activate

# Windows
venv\Scripts\activate
```

### 3. Install Dependencies
```bash
pip install -r requirements.txt
```

**requirements.txt:**
```
fastapi==0.100.0
uvicorn[standard]==0.22.0
pandas==2.2.3
openpyxl==3.1.2
python-multipart
python-dotenv==1.0.1
aiofiles
aiomysql==0.1.1
sqlalchemy==2.0.22
alembic==1.11.1
apscheduler==3.10.1
pydantic==2.5.1
pymysql
```

### 4. Configure Environment Variables

Create `.env` file in backend root:
```bash
# AWS Configuration
AWS_REGION=eu-central-1
AWS_ACCESS_KEY_ID=your_access_key
AWS_SECRET_ACCESS_KEY=your_secret_key
S3_BUCKET=your_bucket_name

# Database Configuration (AWS RDS)
DB_HOST=your-rds-endpoint.rds.amazonaws.com
DB_PORT=3306
DB_NAME=workshop
DB_USER=workshop
DB_PASSWORD=your_secure_password

# Application Configuration
FRONTEND_URL=https://weldingworkshop-f4697.web.app
DATA_DIR=data
```

### 5. Project Structure
```
backend/
├── app/
│   ├── main.py              # FastAPI application
│   ├── models.py            # SQLAlchemy models
│   ├── schemas.py           # Pydantic schemas
│   ├── crud.py              # CRUD operations
│   ├── database.py          # Database setup
│   ├── utils.py             # Excel import helpers
│   └── scheduler.py         # APScheduler jobs
├── aws/
│   ├── deploy.sh            # Linux deployment script
│   └── deploy.ps1           # Windows deployment script
├── data/                    # Local test files
├── uploads/                 # Uploaded files
├── .env                     # Environment variables
├── Dockerfile
├── docker-compose.yml
└── requirements.txt
```

### 6. Run Locally
```bash
# Start FastAPI server
uvicorn app.main:app --reload --host 0.0.0.0 --port 8000

# Access API docs
# http://localhost:8000/docs
```

### 7. Docker Build & Run
```bash
# Build image
docker build -t welding-backend .

# Run container
docker run -p 8000:8000 --env-file .env welding-backend

# Or use docker-compose
docker-compose up -d
```

### 8. Push to DockerHub (Optional)
```bash
# Login
docker login

# Tag image
docker tag welding-backend yourusername/welding-backend:latest

# Push to DockerHub
docker push yourusername/welding-backend:latest

# For updates
docker build -t yourusername/welding-backend:v1.1 .
docker tag yourusername/welding-backend:v1.1 yourusername/welding-backend:latest
docker push yourusername/welding-backend:v1.1
docker push yourusername/welding-backend:latest
```

### 9. Deploy to Render.com

#### Option A: From GitHub
1. Go to [Render.com](https://render.com/)
2. Click **New → Web Service**
3. Connect GitHub repository
4. Configure:
   - **Environment**: Docker
   - **Branch**: main
   - **Service Name**: welding-backend
5. Add environment variables from `.env`
6. Set start command:
   ```bash
   uvicorn app.main:app --host 0.0.0.0 --port 8000
   ```
7. Click **Create Web Service**

#### Option B: From DockerHub
1. Click **New → Web Service**
2. Select **Docker Image**
3. Enter DockerHub credentials
4. Image: `yourusername/welding-backend:latest`
5. Add environment variables
6. Deploy

**Public URL**: `https://welding-backend-v1-0.onrender.com`

**Redeploy After Updates:**
- Auto-Deploy enabled: Render detects changes automatically
- Manual: Dashboard → Service → Deploy → Deploy Latest Image

---

## 📱 Frontend Setup

### 1. Create Flutter Project
```bash
flutter create welding_workshop_app
cd welding_workshop_app
flutter config --enable-web
```

### 2. Update Dependencies

Replace `pubspec.yaml`:
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

```bash
flutter pub get
```

### 3. Project Structure
```
welding_workshop_app/
├── lib/
│   ├── main.dart                    # App entry point
│   ├── config/
│   │   └── api_config.dart          # API base URL
│   ├── models/
│   │   ├── work_order.dart
│   │   ├── equipment.dart
│   │   ├── inspection.dart
│   │   ├── employee.dart
│   │   ├── item.dart
│   │   ├── machine.dart
│   │   └── template.dart
│   ├── services/
│   │   └── api_service.dart         # HTTP API calls
│   ├── providers/
│   │   └── app_provider.dart        # State management
│   ├── screens/
│   │   ├── dashboard_screen.dart
│   │   ├── work_orders_screen.dart
│   │   ├── equipment_screen.dart
│   │   ├── inspections_screen.dart
│   │   ├── employees_screen.dart
│   │   ├── inventory_screen.dart
│   │   └── machines_screen.dart
│   └── widgets/
│       ├── custom_card.dart
│       ├── data_table.dart
│       └── chart_widget.dart
├── web/
│   └── index.html
├── .firebaserc
├── firebase.json
└── pubspec.yaml
```

### 4. Configure Backend URL

**lib/config/api_config.dart:**
```dart
class ApiConfig {
  // Production backend
  static const String baseUrl = 'https://welding-backend-v1-0.onrender.com';
  
  // Local development
  // static const String baseUrl = 'http://localhost:8000';
}
```

### 5. Copy All Code Files

Copy the complete code from the provided documentation into:
- Core files (2): main.dart, api_config.dart
- Model files (7): work_order.dart, equipment.dart, inspection.dart, employee.dart, item.dart, machine.dart, template.dart
- Service & Provider (2): api_service.dart, app_provider.dart
- Screen files (7): dashboard_screen.dart, work_orders_screen.dart, equipment_screen.dart, inspections_screen.dart, employees_screen.dart, inventory_screen.dart, machines_screen.dart
- Widget files (3): custom_card.dart, data_table.dart, chart_widget.dart

**Total: 21 code files**

### 6. Test Locally
```bash
# Run in Chrome
flutter run -d chrome

# Hot reload: press 'r' in terminal
# Check for errors
flutter analyze
```

### 7. Build for Production
```bash
flutter build web --release
```

Output: `build/web/`

---

## 🚀 Deployment

### Backend Deployment to Render.com

**Via GitHub:**
```bash
# Push to GitHub
git add .
git commit -m "Backend ready"
git push origin main

# Render auto-deploys from GitHub
```

**Via DockerHub:**
```bash
# Build and push
docker build -t yourusername/welding-backend:latest .
docker push yourusername/welding-backend:latest

# Deploy on Render from Docker image
```

**Verify Deployment:**
```bash
curl https://welding-backend-v1-0.onrender.com/machines
```

---

### Frontend Deployment to Firebase

#### 1. Initialize Firebase
```bash
firebase login
firebase init hosting
```

**Prompts:**
- **Project**: Select `weldingworkshop-f4697`
- **Public directory**: `build/web`
- **Single-page app**: `Yes`
- **Overwrite index.html**: `No`

#### 2. Configure Firebase

**firebase.json:**
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

**.firebaserc:**
```json
{
  "projects": {
    "default": "weldingworkshop-f4697"
  }
}
```

#### 3. Build and Deploy
```bash
# Build Flutter web
flutter build web --release

# Deploy to Firebase
firebase deploy

# View live
# https://weldingworkshop-f4697.web.app/
```

#### 4. Continuous Deployment
```bash
# Make changes
# Test locally
flutter run -d chrome

# Build and deploy
flutter build web --release
firebase deploy
```

#### 5. Deployment Management
```bash
# View history
firebase hosting:releases

# Rollback
firebase hosting:rollback
```

---

## 📚 API Documentation

### Base URL
```
Production: https://welding-backend-v1-0.onrender.com
Local: http://localhost:8000
```

### Authentication
Currently no authentication. Add JWT tokens for production.

### Endpoints

#### Machines
| Method | Endpoint | Description |
|--------|----------|-------------|
| POST | `/machines` | Create machine |
| GET | `/machines` | List all machines |

**Request Body (POST):**
```json
{
  "name": "Welding Machine A",
  "code": "WM-001",
  "type": "MIG",
  "metadata": {}
}
```

#### Templates
| Method | Endpoint | Description |
|--------|----------|-------------|
| POST | `/templates` | Create template |
| GET | `/templates` | List all templates |

**Request Body (POST):**
```json
{
  "name": "Daily Import Template",
  "description": "Import daily welding data",
  "machine_id": 1,
  "mapping": {
    "Order ID": "order_id",
    "Client": "client",
    "Status": "status"
  }
}
```

#### Work Orders
| Method | Endpoint | Description |
|--------|----------|-------------|
| POST | `/workorders` | Create work order |
| GET | `/workorders` | List all work orders |

**Request Body (POST):**
```json
{
  "order_id": "WO-2024-001",
  "client": "ABC Corp",
  "description": "Steel frame welding",
  "status": "Pending",
  "due_date": "2024-12-31T23:59:59",
  "assigned_welder": "John Doe"
}
```

#### Equipment
| Method | Endpoint | Description |
|--------|----------|-------------|
| POST | `/equipment` | Create equipment |
| GET | `/equipment` | List all equipment |

**Request Body (POST):**
```json
{
  "equipment_id": "EQ-001",
  "name": "MIG Welder",
  "status": "Operational",
  "last_service_date": "2024-11-01T00:00:00"
}
```

#### Inspections
| Method | Endpoint | Description |
|--------|----------|-------------|
| POST | `/inspections` | Create inspection |
| GET | `/inspections` | List all inspections |

**Request Body (POST):**
```json
{
  "inspection_id": "INS-001",
  "order_id": "WO-2024-001",
  "inspector": "Jane Smith",
  "result": "Pass",
  "defect_type": null
}
```

#### Employees
| Method | Endpoint | Description |
|--------|----------|-------------|
| POST | `/employees` | Create employee |
| GET | `/employees` | List all employees |

**Request Body (POST):**
```json
{
  "employee_id": "EMP-001",
  "name": "John Doe",
  "role": "Welder",
  "certification_expiry": "2025-12-31T23:59:59"
}
```

#### Inventory Items
| Method | Endpoint | Description |
|--------|----------|-------------|
| POST | `/items` | Create item |
| GET | `/items` | List all items |

**Request Body (POST):**
```json
{
  "item_id": "ITM-001",
  "item_name": "Steel Rods",
  "quantity": 100,
  "unit": "kg",
  "reorder_level": 20
}
```

#### File Upload
| Method | Endpoint | Description |
|--------|----------|-------------|
| POST | `/upload/{template_id}` | Upload Excel file |

**Request:**
```bash
curl -X POST "https://welding-backend-v1-0.onrender.com/upload/1" \
  -H "Content-Type: multipart/form-data" \
  -F "file=@data.xlsx"
```

**Response:**
```json
{
  "imported": 25
}
```

#### Schedule Import
| Method | Endpoint | Description |
|--------|----------|-------------|
| POST | `/schedule/import/{template_id}` | Schedule daily import |

**Query Parameters:**
- `hour`: Hour of day (0-23)
- `minute`: Minute of hour (0-59)
- `path`: Path to Excel file

**Request:**
```bash
curl -X POST "https://welding-backend-v1-0.onrender.com/schedule/import/1?hour=2&minute=0&path=/uploads/data.xlsx"
```

### Interactive API Docs
```
https://welding-backend-v1-0.onrender.com/docs
```

---

## ⚙️ Configuration

### Backend Configuration

**Environment Variables (.env):**
```bash
# AWS
AWS_REGION=eu-central-1
AWS_ACCESS_KEY_ID=your_key
AWS_SECRET_ACCESS_KEY=your_secret
S3_BUCKET=your_bucket

# Database
DB_HOST=your-rds.amazonaws.com
DB_PORT=3306
DB_NAME=workshop
DB_USER=workshop
DB_PASSWORD=secure_password

# App
FRONTEND_URL=https://weldingworkshop-f4697.web.app
DATA_DIR=data
```

**CORS Configuration (app/main.py):**
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

### Frontend Configuration

**API URL (lib/config/api_config.dart):**
```dart
class ApiConfig {
  static const String baseUrl = 'https://welding-backend-v1-0.onrender.com';
}
```

**Firebase Config:**
- Project ID: `weldingworkshop-f4697`
- Hosting URL: `https://weldingworkshop-f4697.web.app`

---

## 🐛 Troubleshooting

### Backend Issues

**Problem: Database connection fails**
```bash
# Check RDS endpoint
aws rds describe-db-instances --db-instance-identifier workshop-db

# Test connection
mysql -h your-rds-endpoint.amazonaws.com -u workshop -p
```

**Problem: Docker build fails**
```bash
# Clean and rebuild
docker system prune -a
docker build --no-cache -t welding-backend .
```

**Problem: Import scheduler not working**
```bash
# Check logs
docker logs welding-backend

# Verify scheduler started
# Look for "APScheduler started" in logs
```

### Frontend Issues

**Problem: CORS errors**
- Verify backend CORS includes your frontend URL
- Check `app/main.py` origins list
- Redeploy backend after CORS changes

**Problem: Build fails**
```bash
flutter clean
flutter pub get
flutter build web --release
```

**Problem: API calls fail**
- Check `lib/config/api_config.dart` has correct URL
- Verify backend is running
- Test endpoint in browser/Postman
- Check browser console for errors

**Problem: Firebase deploy fails**
```bash
# Re-authenticate
firebase logout
firebase login

# Verify project
firebase projects:list
firebase use weldingworkshop-f4697

# Try again
firebase deploy
```

### Common Errors

**Error: Provider not found**
- Ensure `main.dart` wraps app with `ChangeNotifierProvider`

**Error: Module not found**
```bash
flutter clean
flutter pub get
```

**Error: AWS credentials invalid**
- Regenerate access keys in AWS IAM
- Update `.env` file
- Restart backend

---

## 📊 Usage Guide

### Dashboard
- View real-time statistics
- Interactive charts for work orders and inspections
- Low stock alerts table
- Refresh data with icon button

### Work Orders
- Click "New Order" to create
- Fill: Order ID, Client, Description, Status, Due Date, Welder
- Status: Pending, In Progress, Completed
- Sortable table view

### Equipment
- Add equipment with "Add Equipment" button
- Grid view with status colors
- Track service dates

### Inspections
- Record QC results: Pass/Fail
- Link to work order IDs
- Document defect types
- Color-coded results

### Employees
- Register team members
- Assign roles
- Track certifications

### Inventory
- Add items with quantities
- Set reorder levels
- Low stock alerts

### Machines & Templates
- Configure machines
- Create import templates
- Map Excel columns
- Upload bulk data

---

## 🔒 Security Recommendations

### Production Checklist
- [ ] Enable JWT authentication
- [ ] Use environment variables for secrets
- [ ] Enable HTTPS only
- [ ] Implement rate limiting
- [ ] Add input validation
- [ ] Enable Firebase security rules
- [ ] Use IAM roles instead of access keys
- [ ] Enable RDS encryption
- [ ] Regular security audits
- [ ] Monitor logs for suspicious activity

### Best Practices
- Never commit `.env` files
- Rotate AWS credentials regularly
- Use strong database passwords
- Enable MFA on AWS account
- Implement user roles and permissions
- Regular dependency updates
- Backup database regularly

---

## 🤝 Contributing

### Development Workflow
1. Fork repository
2. Create feature branch: `git checkout -b feature/amazing-feature`
3. Make changes and test
4. Commit: `git commit -m 'Add amazing feature'`
5. Push: `git push origin feature/amazing-feature`
6. Create Pull Request

### Coding Standards
- Follow Dart style guide for Flutter
- Follow PEP 8 for Python
- Write meaningful commit messages
- Comment complex logic
- Write tests for new features
- Update documentation

---

## 📝 License

Proprietary software for welding workshop management.

---

## 📞 Support

### Quick Links
- **Backend Status**: Render.com dashboard
- **Frontend Status**: Firebase console
- **API Docs**: https://welding-backend-v1-0.onrender.com/docs

### Getting Help
1. Check troubleshooting section
2. Review API documentation
3. Check browser console (F12)
4. Review backend logs on Render
5. Contact development team

---

## 🎯 Future Enhancements

### Planned Features
- [ ] User authentication (Firebase Auth)
- [ ] Real-time updates (WebSocket)
- [ ] PDF report generation
- [ ] Mobile apps (iOS/Android)
- [ ] Offline mode with sync
- [ ] Multi-language support
- [ ] Dark mode
- [ ] Push notifications
- [ ] Advanced analytics
- [ ] Barcode scanning

### Technical Improvements
- [ ] Unit tests
- [ ] Integration tests
- [ ] CI/CD pipeline
- [ ] Error monitoring (Sentry)
- [ ] Performance optimization
- [ ] Accessibility (WCAG)

---

## ✅ Quick Start Checklist

### Backend
- [ ] Python 3.11 installed
- [ ] Docker installed
- [ ] AWS account created
- [ ] RDS database configured
- [ ] S3 bucket created
- [ ] `.env` file configured
- [ ] Dependencies installed
- [ ] Backend runs locally
- [ ] Deployed to Render.com

### Frontend
- [ ] Flutter SDK installed
- [ ] Firebase account created
- [ ] Project created
- [ ] All 21 files copied
- [ ] Dependencies installed
- [ ] API URL configured
- [ ] App runs in Chrome
- [ ] Deployed to Firebase
- [ ] Live URL working

---

**Version**: 1.0.0  
**Last Updated**: November 2024  
**Built with**: FastAPI + Flutter + AWS

---

*For detailed code examples and complete file contents, refer to the project documentation.*