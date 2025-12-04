# Backend Development Plan

**Project**: Welding Improvement Workshop Management System  
**Target**: Production-Ready Backend API  
**Timeline**: 6-8 Weeks  
**Date**: December 2024

---

## Overview

This document outlines the comprehensive development plan to bring the backend from its current development state to production-ready status. The plan is organized into phases with clear milestones and deliverables.

---

## Development Phases

### 🎯 Phase 1: Foundation & Critical Fixes (Weeks 1-2)

**Goal**: Establish production foundation and fix critical issues

#### 1.1 Database Migrations Setup

**Tasks:**
- [ ] Initialize Alembic for database migrations
- [ ] Create initial migration from existing models
- [ ] Set up migration scripts for development/production
- [ ] Configure migration environment variables
- [ ] Remove `create_all()` from startup
- [ ] Create migration documentation

**Deliverables:**
- `alembic.ini` configuration file
- Initial migration file
- Migration documentation
- Migration run scripts

**Commands:**
```bash
cd backend
alembic init alembic
alembic revision --autogenerate -m "Initial migration"
alembic upgrade head
```

#### 1.2 Complete CRUD Operations

**Tasks:**
- [ ] Add GET by ID endpoints for all resources
- [ ] Add PUT (full update) endpoints
- [ ] Add PATCH (partial update) endpoints
- [ ] Add DELETE endpoints
- [ ] Add proper error handling (404, 400, 422)
- [ ] Update schemas for update operations
- [ ] Add CRUD tests

**Resources to update:**
- Machines (`/machines/{id}`)
- Templates (`/templates/{id}`)
- Work Orders (`/workorders/{id}`)
- Equipment (`/equipment/{id}`)
- Inspections (`/inspections/{id}`)
- Employees (`/employees/{id}`)
- Items (`/items/{id}`)

**Example Implementation:**
```python
# GET by ID
@app.get("/machines/{machine_id}")
async def get_machine(machine_id: int, db: AsyncSession = Depends(get_db)):
    machine = await crud.get_machine_by_id(db, machine_id)
    if not machine:
        raise HTTPException(status_code=404, detail="Machine not found")
    return machine

# UPDATE
@app.put("/machines/{machine_id}")
async def update_machine(
    machine_id: int,
    body: MachineUpdate,
    db: AsyncSession = Depends(get_db)
):
    machine = await crud.update_machine(db, machine_id, body)
    if not machine:
        raise HTTPException(status_code=404, detail="Machine not found")
    return machine

# DELETE
@app.delete("/machines/{machine_id}")
async def delete_machine(machine_id: int, db: AsyncSession = Depends(get_db)):
    success = await crud.delete_machine(db, machine_id)
    if not success:
        raise HTTPException(status_code=404, detail="Machine not found")
    return {"message": "Machine deleted successfully"}
```

#### 1.3 Error Handling & Logging

**Tasks:**
- [ ] Create custom exception handlers
- [ ] Implement structured logging (JSON format)
- [ ] Add request/response logging
- [ ] Create error response schemas
- [ ] Add logging configuration
- [ ] Implement error tracking (optional: Sentry)

**Files to create:**
- `app/core/logger.py` - Logging configuration
- `app/core/exceptions.py` - Custom exceptions
- `app/core/middleware.py` - Logging middleware
- `app/core/responses.py` - Standard response formats

**Example:**
```python
# app/core/logger.py
import logging
import json
from datetime import datetime

class JSONFormatter(logging.Formatter):
    def format(self, record):
        log_data = {
            "timestamp": datetime.utcnow().isoformat(),
            "level": record.levelname,
            "message": record.getMessage(),
            "module": record.module,
            "function": record.funcName,
            "line": record.lineno
        }
        if hasattr(record, "request_id"):
            log_data["request_id"] = record.request_id
        return json.dumps(log_data)
```

#### 1.4 Health Check & Monitoring

**Tasks:**
- [ ] Create health check endpoint (`/health`)
- [ ] Add database connectivity check
- [ ] Add service status endpoint
- [ ] Create monitoring metrics endpoint (optional)

**Endpoints:**
```
GET /health - Basic health check
GET /health/db - Database connectivity
GET /health/status - Detailed service status
```

---

### 🚀 Phase 2: Production Features (Weeks 3-4)

**Goal**: Add essential production features and functionality

#### 2.1 Query Enhancements (Pagination, Filtering, Sorting)

**Tasks:**
- [ ] Implement pagination for all list endpoints
- [ ] Add filtering capabilities
- [ ] Add sorting options
- [ ] Add field selection
- [ ] Create query parameter schemas
- [ ] Update frontend API service if needed

**Implementation:**
```python
from fastapi import Query
from typing import Optional

@app.get("/workorders")
async def list_workorders(
    skip: int = Query(0, ge=0),
    limit: int = Query(100, ge=1, le=1000),
    status: Optional[str] = None,
    client: Optional[str] = None,
    sort_by: Optional[str] = Query(None, regex="^(order_id|client|due_date|status)$"),
    order: Optional[str] = Query("asc", regex="^(asc|desc)$"),
    db: AsyncSession = Depends(get_db)
):
    return await crud.list_work_orders(
        db, skip=skip, limit=limit, status=status,
        client=client, sort_by=sort_by, order=order
    )
```

**Pagination Response:**
```python
{
    "items": [...],
    "total": 150,
    "page": 1,
    "page_size": 50,
    "pages": 3
}
```

#### 2.2 Dashboard & Analytics Endpoints

**Tasks:**
- [ ] Create dashboard statistics endpoint
- [ ] Add work order statistics
- [ ] Add equipment status summary
- [ ] Add inspection pass/fail rates
- [ ] Add inventory alerts
- [ ] Add employee statistics
- [ ] Create analytics aggregation queries

**Endpoints:**
```
GET /dashboard/stats - Overall statistics
GET /dashboard/workorders - Work order analytics
GET /dashboard/equipment - Equipment status
GET /dashboard/inspections - QC analytics
GET /dashboard/inventory/alerts - Low stock items
```

**Example Response:**
```python
{
    "work_orders": {
        "total": 150,
        "pending": 45,
        "in_progress": 30,
        "completed": 75,
        "overdue": 5
    },
    "equipment": {
        "total": 25,
        "operational": 20,
        "maintenance": 3,
        "out_of_order": 2
    },
    "inspections": {
        "total": 200,
        "pass_rate": 0.95,
        "fail_rate": 0.05
    },
    "inventory_alerts": [
        {"item_id": "ITM-001", "item_name": "Steel Rods", "quantity": 15, "reorder_level": 20}
    ]
}
```

#### 2.3 AWS S3 Integration

**Tasks:**
- [ ] Install boto3 for AWS SDK
- [ ] Create S3 service module
- [ ] Implement file upload to S3
- [ ] Implement file download from S3
- [ ] Add file deletion from S3
- [ ] Update upload endpoint to use S3
- [ ] Add S3 configuration
- [ ] Create file cleanup job

**Files to create:**
- `app/services/s3_service.py` - S3 operations
- `app/config/s3_config.py` - S3 configuration

**Implementation:**
```python
# app/services/s3_service.py
import boto3
from botocore.exceptions import ClientError
from pathlib import Path

class S3Service:
    def __init__(self, bucket_name: str, region: str):
        self.s3_client = boto3.client('s3', region_name=region)
        self.bucket_name = bucket_name
    
    async def upload_file(self, file_path: str, s3_key: str) -> str:
        try:
            self.s3_client.upload_file(file_path, self.bucket_name, s3_key)
            return f"s3://{self.bucket_name}/{s3_key}"
        except ClientError as e:
            raise Exception(f"Failed to upload file: {e}")
    
    async def delete_file(self, s3_key: str):
        try:
            self.s3_client.delete_object(Bucket=self.bucket_name, Key=s3_key)
        except ClientError as e:
            raise Exception(f"Failed to delete file: {e}")
```

#### 2.4 Input Validation & Sanitization

**Tasks:**
- [ ] Add file upload validation (type, size)
- [ ] Add input sanitization
- [ ] Create validation middleware
- [ ] Add Pydantic validators
- [ ] Implement file type checking

**Validation Rules:**
- Excel files only (.xlsx, .xls)
- Max file size: 10MB
- Validate all string inputs
- Sanitize file paths
- Validate date formats

---

### 🔒 Phase 3: Security & Authentication (Weeks 5-6)

**Goal**: Implement comprehensive security measures

#### 3.1 Authentication System

**Tasks:**
- [ ] Choose authentication method (JWT recommended)
- [ ] Install security dependencies (python-jose, passlib, bcrypt)
- [ ] Create user model and authentication
- [ ] Implement login endpoint
- [ ] Implement token generation/refresh
- [ ] Add authentication middleware
- [ ] Protect all endpoints (except public ones)
- [ ] Create user management endpoints

**Dependencies:**
```txt
python-jose[cryptography]==3.3.0
passlib[bcrypt]==1.7.4
python-multipart==0.0.6
```

**Implementation:**
```python
# app/core/security.py
from jose import JWTError, jwt
from passlib.context import CryptContext
from datetime import datetime, timedelta

pwd_context = CryptContext(schemes=["bcrypt"], deprecated="auto")

def verify_password(plain_password: str, hashed_password: str) -> bool:
    return pwd_context.verify(plain_password, hashed_password)

def get_password_hash(password: str) -> str:
    return pwd_context.hash(password)

def create_access_token(data: dict, expires_delta: timedelta = None):
    to_encode = data.copy()
    if expires_delta:
        expire = datetime.utcnow() + expires_delta
    else:
        expire = datetime.utcnow() + timedelta(minutes=15)
    to_encode.update({"exp": expire})
    encoded_jwt = jwt.encode(to_encode, SECRET_KEY, algorithm=ALGORITHM)
    return encoded_jwt
```

#### 3.2 Authorization & Permissions

**Tasks:**
- [ ] Create role-based access control (RBAC)
- [ ] Define user roles (admin, manager, operator, viewer)
- [ ] Implement permission decorators
- [ ] Add role checks to endpoints
- [ ] Create permission models

**Roles:**
- `admin` - Full access
- `manager` - Create/update/delete operations
- `operator` - Create/update own work
- `viewer` - Read-only access

#### 3.3 Rate Limiting

**Tasks:**
- [ ] Install slowapi or similar
- [ ] Configure rate limits
- [ ] Add rate limit middleware
- [ ] Set different limits for different endpoints

**Configuration:**
- General endpoints: 100 requests/minute
- Upload endpoints: 10 requests/minute
- Authentication: 5 requests/minute

#### 3.4 Security Enhancements

**Tasks:**
- [ ] Add HTTPS enforcement
- [ ] Implement CORS properly (remove wildcards)
- [ ] Add request size limits
- [ ] Implement CSRF protection
- [ ] Add security headers
- [ ] Configure secrets management

---

### 🧪 Phase 4: Testing & Documentation (Weeks 7-8)

**Goal**: Comprehensive testing and documentation

#### 4.1 Unit Testing

**Tasks:**
- [ ] Set up pytest configuration
- [ ] Create test database setup
- [ ] Write unit tests for CRUD operations
- [ ] Write unit tests for utilities
- [ ] Write unit tests for services
- [ ] Aim for 80%+ code coverage

**Test Structure:**
```
backend/
├── tests/
│   ├── conftest.py
│   ├── unit/
│   │   ├── test_crud.py
│   │   ├── test_utils.py
│   │   └── test_services.py
│   ├── integration/
│   │   ├── test_api_endpoints.py
│   │   └── test_database.py
│   └── fixtures/
```

#### 4.2 Integration Testing

**Tasks:**
- [ ] Test API endpoints
- [ ] Test database operations
- [ ] Test file upload/download
- [ ] Test authentication flow
- [ ] Test error scenarios

#### 4.3 API Documentation

**Tasks:**
- [ ] Complete OpenAPI/Swagger documentation
- [ ] Add detailed endpoint descriptions
- [ ] Add request/response examples
- [ ] Document error codes
- [ ] Create API usage guide
- [ ] Add authentication documentation

#### 4.4 Code Documentation

**Tasks:**
- [ ] Add docstrings to all functions
- [ ] Document complex logic
- [ ] Create architecture diagrams
- [ ] Update README.md
- [ ] Create deployment guides
- [ ] Document configuration options

---

## Implementation Priority

### Must-Have (Critical Path)
1. ✅ Database migrations
2. ✅ Complete CRUD operations
3. ✅ Error handling & logging
4. ✅ Health check endpoint
5. ✅ Authentication system

### Should-Have (Important)
6. ✅ Pagination & filtering
7. ✅ Dashboard endpoints
8. ✅ AWS S3 integration
9. ✅ Input validation
10. ✅ Rate limiting

### Nice-to-Have (Enhancement)
11. Testing (comprehensive)
12. Advanced analytics
13. Caching layer
14. Real-time updates (WebSocket)

---

## File Structure (Target)

```
backend/
├── app/
│   ├── __init__.py
│   ├── main.py                    # FastAPI app
│   ├── core/
│   │   ├── config.py             # Configuration
│   │   ├── security.py           # Auth & security
│   │   ├── exceptions.py         # Custom exceptions
│   │   ├── logger.py             # Logging
│   │   └── middleware.py         # Custom middleware
│   ├── api/
│   │   ├── v1/
│   │   │   ├── __init__.py
│   │   │   ├── endpoints/
│   │   │   │   ├── machines.py
│   │   │   │   ├── templates.py
│   │   │   │   ├── workorders.py
│   │   │   │   ├── equipment.py
│   │   │   │   ├── inspections.py
│   │   │   │   ├── employees.py
│   │   │   │   ├── items.py
│   │   │   │   ├── dashboard.py
│   │   │   │   └── auth.py
│   │   │   └── api.py            # Router aggregation
│   ├── models/
│   │   └── (existing models)
│   ├── schemas/
│   │   └── (existing schemas + updates)
│   ├── crud/
│   │   └── (existing crud + updates)
│   ├── services/
│   │   ├── s3_service.py
│   │   └── analytics_service.py
│   ├── utils/
│   │   └── (existing utils)
│   └── database.py
├── alembic/
│   ├── versions/
│   └── env.py
├── tests/
│   ├── unit/
│   ├── integration/
│   └── fixtures/
├── alembic.ini
├── requirements.txt
├── requirements-dev.txt
├── Dockerfile
└── .env.example
```

---

## Dependencies to Add

### Phase 1
```txt
alembic==1.13.1
```

### Phase 2
```txt
boto3==1.34.0
slowapi==0.1.9  # Rate limiting
```

### Phase 3
```txt
python-jose[cryptography]==3.3.0
passlib[bcrypt]==1.7.4
```

### Phase 4
```txt
pytest==7.4.4
pytest-asyncio==0.23.3
pytest-cov==4.1.0
httpx==0.26.0  # For testing FastAPI
```

---

## Success Criteria

### Phase 1
- ✅ Database migrations working
- ✅ All CRUD operations implemented
- ✅ Error handling in place
- ✅ Health check responding

### Phase 2
- ✅ Pagination working
- ✅ Dashboard endpoints returning data
- ✅ Files uploading to S3
- ✅ Input validation active

### Phase 3
- ✅ Users can authenticate
- ✅ Endpoints protected
- ✅ Rate limiting active
- ✅ Security audit passed

### Phase 4
- ✅ Test coverage > 80%
- ✅ All endpoints documented
- ✅ Deployment guide complete
- ✅ Ready for production

---

## Risk Mitigation

### Technical Risks
- **Database migration issues**: Test migrations in staging first
- **S3 integration failures**: Implement fallback to local storage
- **Performance issues**: Load testing before production
- **Breaking changes**: Version API endpoints (v1/)

### Timeline Risks
- **Scope creep**: Stick to defined phases
- **Unexpected issues**: Buffer time in each phase
- **Dependency conflicts**: Test in isolated environment

---

## Next Steps

1. Review and approve this plan
2. Set up development environment
3. Create feature branches for each phase
4. Begin Phase 1 implementation
5. Weekly progress reviews

---

**Document Version**: 1.0  
**Created**: December 2024  
**Next Review**: After Phase 1 completion

