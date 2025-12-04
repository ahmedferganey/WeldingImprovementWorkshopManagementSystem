# Comprehensive Implementation Plan

**Project**: Welding Improvement Workshop Management System - Backend  
**Date**: December 2024  
**Purpose**: Detailed action plan to address all identified issues and missing features

---

## 📋 Table of Contents

1. [Overview](#overview)
2. [Phase 1: Critical Foundation (Weeks 1-2)](#phase-1-critical-foundation-weeks-1-2)
3. [Phase 2: Production Features (Weeks 3-4)](#phase-2-production-features-weeks-3-4)
4. [Phase 3: Security & Monitoring (Weeks 5-6)](#phase-3-security--monitoring-weeks-5-6)
5. [Phase 4: Testing & Documentation (Weeks 7-8)](#phase-4-testing--documentation-weeks-7-8)
6. [Implementation Checklist](#implementation-checklist)
7. [File Structure Changes](#file-structure-changes)

---

## Overview

This plan addresses all issues identified in the Current State Assessment:
- ❌ Missing Features (Critical for Production)
- ❌ Code Quality Issues
- ❌ Security Concerns
- ❌ Performance Considerations
- ❌ Missing Documentation
- ❌ Frontend Integration Gaps

**Timeline**: 8 weeks  
**Approach**: Phased development with clear milestones

---

## Phase 1: Critical Foundation (Weeks 1-2)

### Week 1: Database & Core Infrastructure

#### 1.1 Database Migrations Setup ⭐ CRITICAL

**Task**: Replace `create_all()` with Alembic migrations

**Actions**:
- [ ] Install Alembic: `pip install alembic==1.13.1`
- [ ] Initialize Alembic: `alembic init alembic`
- [ ] Configure `alembic/env.py` for async MySQL
- [ ] Create initial migration: `alembic revision --autogenerate -m "Initial migration"`
- [ ] Review and adjust migration file
- [ ] Create migration run script
- [ ] Remove `create_all()` from `app/main.py:29-33`
- [ ] Update startup sequence to run migrations
- [ ] Test migrations on clean database
- [ ] Document migration process

**Files to Create/Modify**:
```
backend/
├── alembic.ini (created)
├── alembic/
│   ├── env.py (configure for async)
│   ├── script.py.mako
│   └── versions/
│       └── xxxx_initial_migration.py
├── app/main.py (remove create_all)
└── scripts/
    └── migrate.py (migration runner)
```

**Code Changes**:
```python
# app/main.py - REMOVE THIS:
@app.on_event("startup")
async def on_start():
    async with engine.begin() as conn:
        await conn.run_sync(Base.metadata.create_all)  # ❌ REMOVE
    scheduler.start_scheduler()

# REPLACE WITH:
@app.on_event("startup")
async def on_start():
    # Migrations should run separately before app starts
    # Run: alembic upgrade head
    scheduler.start_scheduler()
```

**Success Criteria**:
- ✅ Alembic migrations working
- ✅ Can create/upgrade/downgrade database
- ✅ No `create_all()` in code

---

#### 1.2 Complete CRUD Operations ⭐ CRITICAL

**Task**: Implement GET by ID, UPDATE, DELETE for all resources

**Resources to Update**: Machines, Templates, WorkOrders, Equipment, Inspections, Employees, Items

**Actions for Each Resource**:

##### A. GET by ID Endpoints

- [ ] Add GET endpoint: `GET /machines/{machine_id}`
- [ ] Add GET endpoint: `GET /templates/{template_id}`
- [ ] Add GET endpoint: `GET /workorders/{workorder_id}`
- [ ] Add GET endpoint: `GET /equipment/{equipment_id}`
- [ ] Add GET endpoint: `GET /inspections/{inspection_id}`
- [ ] Add GET endpoint: `GET /employees/{employee_id}`
- [ ] Add GET endpoint: `GET /items/{item_id}`

**Implementation Pattern**:
```python
# app/crud.py
async def get_machine_by_id(db: AsyncSession, machine_id: int):
    result = await db.execute(
        select(Machine).where(Machine.id == machine_id)
    )
    return result.scalar_one_or_none()

# app/main.py (or routers)
@app.get("/machines/{machine_id}", response_model=MachineOut)
async def get_machine(
    machine_id: int,
    db: AsyncSession = Depends(get_db)
):
    machine = await crud.get_machine_by_id(db, machine_id)
    if not machine:
        raise HTTPException(status_code=404, detail="Machine not found")
    return machine
```

##### B. UPDATE Endpoints (PUT - Full Update)

- [ ] Add PUT endpoint: `PUT /machines/{machine_id}`
- [ ] Add PUT endpoint: `PUT /templates/{template_id}`
- [ ] Add PUT endpoint: `PUT /workorders/{workorder_id}`
- [ ] Add PUT endpoint: `PUT /equipment/{equipment_id}`
- [ ] Add PUT endpoint: `PUT /inspections/{inspection_id}`
- [ ] Add PUT endpoint: `PUT /employees/{employee_id}`
- [ ] Add PUT endpoint: `PUT /items/{item_id}`

**Implementation Pattern**:
```python
# app/schemas.py - Add update schemas
class MachineUpdate(BaseModel):
    name: Optional[str] = None
    code: Optional[str] = None
    type: Optional[str] = None
    metadata: Optional[Dict[str, Any]] = None

# app/crud.py
async def update_machine(
    db: AsyncSession,
    machine_id: int,
    machine_update: MachineUpdate
):
    machine = await db.get(Machine, machine_id)
    if not machine:
        return None
    
    update_data = machine_update.model_dump(exclude_unset=True)
    for field, value in update_data.items():
        setattr(machine, field, value)
    
    await db.commit()
    await db.refresh(machine)
    return machine
```

##### C. PATCH Endpoints (Partial Update)

- [ ] Add PATCH endpoint: `PATCH /machines/{machine_id}`
- [ ] Add PATCH endpoint: `PATCH /templates/{template_id}`
- [ ] Add PATCH endpoint: `PATCH /workorders/{workorder_id}`
- [ ] Add PATCH endpoint: `PATCH /equipment/{equipment_id}`
- [ ] Add PATCH endpoint: `PATCH /inspections/{inspection_id}`
- [ ] Add PATCH endpoint: `PATCH /employees/{employee_id}`
- [ ] Add PATCH endpoint: `PATCH /items/{item_id}`

##### D. DELETE Endpoints

- [ ] Add DELETE endpoint: `DELETE /machines/{machine_id}`
- [ ] Add DELETE endpoint: `DELETE /templates/{template_id}`
- [ ] Add DELETE endpoint: `DELETE /workorders/{workorder_id}`
- [ ] Add DELETE endpoint: `DELETE /equipment/{equipment_id}`
- [ ] Add DELETE endpoint: `DELETE /inspections/{inspection_id}`
- [ ] Add DELETE endpoint: `DELETE /employees/{employee_id}`
- [ ] Add DELETE endpoint: `DELETE /items/{item_id}`

**Implementation Pattern**:
```python
async def delete_machine(db: AsyncSession, machine_id: int) -> bool:
    machine = await db.get(Machine, machine_id)
    if not machine:
        return False
    
    await db.delete(machine)
    await db.commit()
    return True
```

**Success Criteria**:
- ✅ All 7 resources have GET by ID
- ✅ All 7 resources have PUT endpoints
- ✅ All 7 resources have PATCH endpoints
- ✅ All 7 resources have DELETE endpoints
- ✅ Proper error handling (404 for not found)
- ✅ Frontend can update/delete records

---

#### 1.3 Error Handling & Logging System ⭐ CRITICAL

**Task**: Implement comprehensive error handling and structured logging

**Actions**:

##### A. Structured Logging

- [ ] Create `app/core/logger.py`
- [ ] Configure JSON formatter for logs
- [ ] Set up log levels (DEBUG, INFO, WARNING, ERROR, CRITICAL)
- [ ] Add request ID tracking
- [ ] Configure log rotation
- [ ] Add logging middleware
- [ ] Integrate logging in all modules

**Implementation**:
```python
# app/core/logger.py
import logging
import json
from datetime import datetime
from typing import Any
import sys

class JSONFormatter(logging.Formatter):
    def format(self, record: logging.LogRecord) -> str:
        log_data = {
            "timestamp": datetime.utcnow().isoformat(),
            "level": record.levelname,
            "message": record.getMessage(),
            "module": record.module,
            "function": record.funcName,
            "line": record.lineno,
        }
        
        if hasattr(record, "request_id"):
            log_data["request_id"] = record.request_id
        
        if record.exc_info:
            log_data["exception"] = self.formatException(record.exc_info)
        
        return json.dumps(log_data)

def setup_logging(log_level: str = "INFO"):
    logger = logging.getLogger("app")
    logger.setLevel(getattr(logging, log_level))
    
    handler = logging.StreamHandler(sys.stdout)
    handler.setFormatter(JSONFormatter())
    logger.addHandler(handler)
    
    return logger
```

##### B. Custom Exception Handlers

- [ ] Create `app/core/exceptions.py`
- [ ] Define custom exception classes
- [ ] Create exception handler middleware
- [ ] Add standard error response format
- [ ] Handle validation errors
- [ ] Handle database errors
- [ ] Handle authentication errors

**Implementation**:
```python
# app/core/exceptions.py
from fastapi import Request, status
from fastapi.responses import JSONResponse
from fastapi.exceptions import RequestValidationError
from sqlalchemy.exc import IntegrityError
import logging

logger = logging.getLogger("app")

class CustomHTTPException(Exception):
    def __init__(self, status_code: int, detail: str, error_code: str = None):
        self.status_code = status_code
        self.detail = detail
        self.error_code = error_code

async def custom_exception_handler(request: Request, exc: CustomHTTPException):
    return JSONResponse(
        status_code=exc.status_code,
        content={
            "detail": exc.detail,
            "error_code": exc.error_code,
            "timestamp": datetime.utcnow().isoformat()
        }
    )

async def validation_exception_handler(request: Request, exc: RequestValidationError):
    return JSONResponse(
        status_code=status.HTTP_422_UNPROCESSABLE_ENTITY,
        content={
            "detail": "Validation error",
            "errors": exc.errors(),
            "timestamp": datetime.utcnow().isoformat()
        }
    )

async def integrity_error_handler(request: Request, exc: IntegrityError):
    logger.error(f"Database integrity error: {str(exc)}")
    return JSONResponse(
        status_code=status.HTTP_409_CONFLICT,
        content={
            "detail": "Resource conflict - duplicate or constraint violation",
            "error_code": "DUPLICATE_RESOURCE",
            "timestamp": datetime.utcnow().isoformat()
        }
    )
```

##### C. Transaction Management

- [ ] Add transaction rollback on errors
- [ ] Wrap bulk operations in transactions
- [ ] Add transaction retry logic
- [ ] Improve error handling in CRUD operations

**Implementation**:
```python
# app/crud.py - Update all functions
async def create_machine(db: AsyncSession, obj: MachineCreate):
    try:
        m = Machine(**obj.model_dump())
        db.add(m)
        await db.commit()
        await db.refresh(m)
        return m
    except IntegrityError as e:
        await db.rollback()
        logger.error(f"Integrity error creating machine: {str(e)}")
        raise CustomHTTPException(
            status_code=409,
            detail="Machine with this code already exists",
            error_code="DUPLICATE_RESOURCE"
        )
    except Exception as e:
        await db.rollback()
        logger.error(f"Error creating machine: {str(e)}", exc_info=True)
        raise CustomHTTPException(
            status_code=500,
            detail="Failed to create machine",
            error_code="SERVER_ERROR"
        )
```

**Success Criteria**:
- ✅ Structured JSON logging working
- ✅ All exceptions properly handled
- ✅ Transactions rollback on errors
- ✅ Request tracking implemented
- ✅ Logs formatted and searchable

---

#### 1.4 Health Check Endpoint ⭐ CRITICAL

**Task**: Create health check endpoints for monitoring

**Actions**:
- [ ] Create `GET /health` endpoint
- [ ] Create `GET /health/db` endpoint (database connectivity)
- [ ] Create `GET /health/status` endpoint (detailed status)
- [ ] Add service version info
- [ ] Add uptime tracking

**Implementation**:
```python
# app/api/v1/endpoints/health.py
from fastapi import APIRouter, Depends
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import text
from datetime import datetime
from app.database import get_db
import os

router = APIRouter()

@router.get("/health")
async def health_check():
    return {
        "status": "healthy",
        "timestamp": datetime.utcnow().isoformat(),
        "version": os.getenv("APP_VERSION", "1.0.0")
    }

@router.get("/health/db")
async def health_db(db: AsyncSession = Depends(get_db)):
    try:
        result = await db.execute(text("SELECT 1"))
        result.scalar()
        return {
            "status": "healthy",
            "database": "connected",
            "timestamp": datetime.utcnow().isoformat()
        }
    except Exception as e:
        return {
            "status": "unhealthy",
            "database": "disconnected",
            "error": str(e),
            "timestamp": datetime.utcnow().isoformat()
        }

@router.get("/health/status")
async def health_status(db: AsyncSession = Depends(get_db)):
    db_status = "unknown"
    try:
        await db.execute(text("SELECT 1"))
        db_status = "healthy"
    except:
        db_status = "unhealthy"
    
    return {
        "status": "healthy" if db_status == "healthy" else "degraded",
        "components": {
            "database": db_status,
            "api": "healthy"
        },
        "timestamp": datetime.utcnow().isoformat()
    }
```

**Success Criteria**:
- ✅ Health endpoints responding
- ✅ Database connectivity check working
- ✅ Monitoring tools can use endpoints

---

### Week 2: File Security & Scheduler Improvements

#### 2.1 File Upload Security ⭐ CRITICAL

**Task**: Fix file upload vulnerabilities and add validation

**Actions**:
- [ ] Add file type validation (.xlsx, .xls only)
- [ ] Add file size limits (max 10MB)
- [ ] Sanitize filenames (prevent path traversal)
- [ ] Add file content validation
- [ ] Improve error messages
- [ ] Add upload logging

**Implementation**:
```python
# app/core/file_validation.py
from pathlib import Path
from fastapi import UploadFile, HTTPException
import magic  # python-magic for file type detection

MAX_FILE_SIZE = 10 * 1024 * 1024  # 10MB
ALLOWED_EXTENSIONS = {'.xlsx', '.xls'}
ALLOWED_MIME_TYPES = {
    'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
    'application/vnd.ms-excel'
}

def validate_file(file: UploadFile) -> None:
    # Check file extension
    file_ext = Path(file.filename).suffix.lower()
    if file_ext not in ALLOWED_EXTENSIONS:
        raise HTTPException(
            status_code=400,
            detail=f"Invalid file type. Only Excel files (.xlsx, .xls) are allowed."
        )
    
    # Check file size (if available)
    if hasattr(file, 'size') and file.size > MAX_FILE_SIZE:
        raise HTTPException(
            status_code=400,
            detail=f"File size exceeds maximum allowed size of {MAX_FILE_SIZE / 1024 / 1024}MB"
        )
    
    # Sanitize filename
    safe_filename = Path(file.filename).stem.replace('..', '').replace('/', '').replace('\\', '')
    if not safe_filename:
        raise HTTPException(status_code=400, detail="Invalid filename")

# Update upload endpoint
@app.post("/upload/{template_id}")
async def upload_excel(
    template_id: int,
    file: UploadFile = File(...),
    db: AsyncSession = Depends(get_db)
):
    # Validate file
    validate_file(file)
    
    # Read file content with size check
    content = await file.read()
    if len(content) > MAX_FILE_SIZE:
        raise HTTPException(
            status_code=400,
            detail=f"File size exceeds {MAX_FILE_SIZE / 1024 / 1024}MB"
        )
    
    # Sanitize filename
    safe_filename = Path(file.filename).stem.replace('..', '').replace('/', '').replace('\\', '')
    file_ext = Path(file.filename).suffix.lower()
    filename = f"{uuid.uuid4()}_{safe_filename}{file_ext}"
    
    # Save file (temporary, will move to S3 in Phase 2)
    uploads_dir = Path("./uploads")
    uploads_dir.mkdir(parents=True, exist_ok=True)
    filepath = uploads_dir / filename
    
    with open(filepath, "wb") as f:
        f.write(content)
    
    # Process import with error handling
    try:
        tpl = await db.get(models.Template, template_id)
        if not tpl:
            raise HTTPException(404, "Template not found")
        
        entries = utils.import_excel_to_entries(str(filepath), tpl.mapping)
        
        # Use transaction
        try:
            for data in entries:
                we = models.WorkshopEntry(
                    template_id=template_id,
                    machine_id=tpl.machine_id,
                    data=data
                )
                db.add(we)
            await db.commit()
            logger.info(f"Imported {len(entries)} entries from {filename}")
            return {"imported": len(entries)}
        except Exception as e:
            await db.rollback()
            logger.error(f"Import failed: {str(e)}", exc_info=True)
            raise HTTPException(500, f"Import failed: {str(e)}")
    except HTTPException:
        raise
    except Exception as e:
        logger.error(f"Upload processing failed: {str(e)}", exc_info=True)
        raise HTTPException(500, "File processing failed")
```

**Success Criteria**:
- ✅ File type validation working
- ✅ File size limits enforced
- ✅ Path traversal prevented
- ✅ Error handling comprehensive

---

#### 2.2 Scheduler Error Handling ⭐ CRITICAL

**Task**: Fix scheduler silent failures

**Actions**:
- [ ] Add try-except blocks to scheduler jobs
- [ ] Add logging to scheduler
- [ ] Add retry mechanism
- [ ] Add job status tracking
- [ ] Add error notifications

**Implementation**:
```python
# app/scheduler.py
import logging
from pathlib import Path
from apscheduler.schedulers.asyncio import AsyncIOScheduler
from apscheduler.triggers.cron import CronTrigger
from .utils import import_excel_to_entries
from .models import WorkshopEntry, Template, ExcelImport
from .database import AsyncSessionLocal

logger = logging.getLogger("app")
scheduler = AsyncIOScheduler()

async def run_import_job(filepath: str, template_id: int):
    """Run import job with comprehensive error handling"""
    job_id = f"import_{template_id}"
    
    try:
        # Check if file exists
        file_path = Path(filepath)
        if not file_path.exists():
            logger.error(f"Import job {job_id}: File not found: {filepath}")
            await update_import_status(template_id, "failed", {"error": "File not found"})
            return
        
        async with AsyncSessionLocal() as session:
            # Get template
            tpl = await session.get(Template, template_id)
            if not tpl:
                logger.error(f"Import job {job_id}: Template {template_id} not found")
                await update_import_status(template_id, "failed", {"error": "Template not found"})
                return
            
            # Update status to running
            await update_import_status(template_id, "running", {})
            
            # Import entries
            entries = import_excel_to_entries(str(filepath), tpl.mapping)
            logger.info(f"Import job {job_id}: Processing {len(entries)} entries")
            
            # Add entries to database
            try:
                for data in entries:
                    we = WorkshopEntry(
                        template_id=template_id,
                        machine_id=tpl.machine_id,
                        data=data
                    )
                    session.add(we)
                
                await session.commit()
                logger.info(f"Import job {job_id}: Successfully imported {len(entries)} entries")
                await update_import_status(template_id, "completed", {"imported": len(entries)})
                
            except Exception as db_error:
                await session.rollback()
                logger.error(f"Import job {job_id}: Database error: {str(db_error)}", exc_info=True)
                await update_import_status(template_id, "failed", {"error": str(db_error)})
                raise
    
    except Exception as e:
        logger.error(f"Import job {job_id}: Failed: {str(e)}", exc_info=True)
        await update_import_status(template_id, "failed", {"error": str(e)})
        # Optionally: Send alert, email notification, etc.

async def update_import_status(template_id: int, status: str, details: dict):
    """Update import status in database"""
    async with AsyncSessionLocal() as session:
        # Find or create ExcelImport record
        # Update status and details
        # Commit
        pass
```

**Success Criteria**:
- ✅ All scheduler errors logged
- ✅ Job status tracked in database
- ✅ No silent failures
- ✅ Error notifications working

---

## Phase 2: Production Features (Weeks 3-4)

### Week 3: Query Enhancements & Dashboard

#### 3.1 Pagination Implementation ⭐ HIGH PRIORITY

**Task**: Add pagination to all list endpoints

**Actions**:
- [ ] Create pagination utility functions
- [ ] Add pagination to GET /machines
- [ ] Add pagination to GET /templates
- [ ] Add pagination to GET /workorders
- [ ] Add pagination to GET /equipment
- [ ] Add pagination to GET /inspections
- [ ] Add pagination to GET /employees
- [ ] Add pagination to GET /items

**Implementation**:
```python
# app/core/pagination.py
from typing import Generic, TypeVar, List
from pydantic import BaseModel
from fastapi import Query

T = TypeVar('T')

class PaginationParams:
    def __init__(
        self,
        skip: int = Query(0, ge=0, description="Number of records to skip"),
        limit: int = Query(100, ge=1, le=1000, description="Number of records to return")
    ):
        self.skip = skip
        self.limit = limit

class PaginatedResponse(BaseModel, Generic[T]):
    items: List[T]
    total: int
    skip: int
    limit: int
    has_more: bool
    
    @property
    def pages(self) -> int:
        return (self.total + self.limit - 1) // self.limit
    
    @property
    def current_page(self) -> int:
        return (self.skip // self.limit) + 1

# Update list endpoints
@app.get("/machines", response_model=PaginatedResponse[MachineOut])
async def list_machines(
    pagination: PaginationParams = Depends(),
    db: AsyncSession = Depends(get_db)
):
    total = await crud.count_machines(db)
    items = await crud.list_machines(db, skip=pagination.skip, limit=pagination.limit)
    
    return PaginatedResponse(
        items=items,
        total=total,
        skip=pagination.skip,
        limit=pagination.limit,
        has_more=(pagination.skip + pagination.limit) < total
    )
```

**Success Criteria**:
- ✅ All list endpoints support pagination
- ✅ Frontend can request specific pages
- ✅ Performance improved for large datasets

---

#### 3.2 Filtering & Sorting ⭐ HIGH PRIORITY

**Task**: Add filtering and sorting capabilities

**Actions**:
- [ ] Create filter schemas for each resource
- [ ] Add filtering to all list endpoints
- [ ] Add sorting to all list endpoints
- [ ] Document filter parameters
- [ ] Add date range filtering

**Implementation**:
```python
# app/core/filters.py
from typing import Optional
from datetime import datetime
from fastapi import Query

class WorkOrderFilters:
    def __init__(
        self,
        status: Optional[str] = Query(None, description="Filter by status"),
        client: Optional[str] = Query(None, description="Filter by client"),
        assigned_welder: Optional[str] = Query(None, description="Filter by welder"),
        due_from: Optional[datetime] = Query(None, description="Filter by due date (from)"),
        due_to: Optional[datetime] = Query(None, description="Filter by due date (to)"),
        sort_by: Optional[str] = Query("id", regex="^(id|order_id|client|due_date|status)$"),
        order: Optional[str] = Query("asc", regex="^(asc|desc)$")
    ):
        self.status = status
        self.client = client
        self.assigned_welder = assigned_welder
        self.due_from = due_from
        self.due_to = due_to
        self.sort_by = sort_by
        self.order = order

# Update CRUD functions
async def list_work_orders(
    db: AsyncSession,
    skip: int = 0,
    limit: int = 100,
    filters: WorkOrderFilters = None
):
    query = select(WorkOrder)
    
    # Apply filters
    if filters:
        if filters.status:
            query = query.where(WorkOrder.status == filters.status)
        if filters.client:
            query = query.where(WorkOrder.client.contains(filters.client))
        if filters.due_from:
            query = query.where(WorkOrder.due_date >= filters.due_from)
        if filters.due_to:
            query = query.where(WorkOrder.due_date <= filters.due_to)
        
        # Apply sorting
        if filters.sort_by:
            sort_column = getattr(WorkOrder, filters.sort_by)
            if filters.order == "desc":
                query = query.order_by(sort_column.desc())
            else:
                query = query.order_by(sort_column.asc())
    
    # Get total count
    count_query = select(func.count()).select_from(query.subquery())
    total = await db.execute(count_query)
    total_count = total.scalar()
    
    # Apply pagination
    query = query.offset(skip).limit(limit)
    
    result = await db.execute(query)
    return result.scalars().all(), total_count
```

**Success Criteria**:
- ✅ All endpoints support filtering
- ✅ All endpoints support sorting
- ✅ Date range filtering working
- ✅ Frontend can filter/sort data

---

#### 3.3 Dashboard & Analytics Endpoints ⭐ HIGH PRIORITY

**Task**: Create dashboard statistics endpoints

**Actions**:
- [ ] Create `GET /dashboard/stats` endpoint
- [ ] Create `GET /dashboard/workorders` endpoint
- [ ] Create `GET /dashboard/equipment` endpoint
- [ ] Create `GET /dashboard/inspections` endpoint
- [ ] Create `GET /dashboard/inventory/alerts` endpoint
- [ ] Add aggregation queries
- [ ] Add date range filtering

**Implementation**:
```python
# app/api/v1/endpoints/dashboard.py
from fastapi import APIRouter, Depends
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select, func
from datetime import datetime, timedelta
from app.database import get_db
from app.models import WorkOrder, Equipment, Inspection, Item

router = APIRouter()

@router.get("/dashboard/stats")
async def get_dashboard_stats(db: AsyncSession = Depends(get_db)):
    # Work Orders Stats
    wo_total = await db.execute(select(func.count(WorkOrder.id)))
    wo_by_status = await db.execute(
        select(WorkOrder.status, func.count(WorkOrder.id))
        .group_by(WorkOrder.status)
    )
    
    # Equipment Stats
    eq_total = await db.execute(select(func.count(Equipment.id)))
    eq_by_status = await db.execute(
        select(Equipment.status, func.count(Equipment.id))
        .group_by(Equipment.status)
    )
    
    # Inspection Stats
    insp_total = await db.execute(select(func.count(Inspection.id)))
    insp_passed = await db.execute(
        select(func.count(Inspection.id))
        .where(Inspection.result == "Pass")
    )
    
    # Inventory Alerts
    low_stock = await db.execute(
        select(Item)
        .where(Item.quantity <= Item.reorder_level)
    )
    
    return {
        "work_orders": {
            "total": wo_total.scalar(),
            "by_status": {row[0]: row[1] for row in wo_by_status.all()}
        },
        "equipment": {
            "total": eq_total.scalar(),
            "by_status": {row[0]: row[1] for row in eq_by_status.all()}
        },
        "inspections": {
            "total": insp_total.scalar(),
            "passed": insp_passed.scalar(),
            "pass_rate": insp_passed.scalar() / insp_total.scalar() if insp_total.scalar() > 0 else 0
        },
        "inventory_alerts": [
            {
                "item_id": item.item_id,
                "item_name": item.item_name,
                "quantity": item.quantity,
                "reorder_level": item.reorder_level
            }
            for item in low_stock.scalars().all()
        ]
    }
```

**Success Criteria**:
- ✅ Dashboard endpoints returning data
- ✅ Frontend can display statistics
- ✅ Aggregation queries optimized

---

### Week 4: AWS S3 Integration & Configuration

#### 4.1 AWS S3 Integration ⭐ HIGH PRIORITY

**Task**: Move file storage to AWS S3

**Actions**:
- [ ] Install boto3: `pip install boto3==1.34.0`
- [ ] Create `app/services/s3_service.py`
- [ ] Configure S3 client
- [ ] Implement file upload to S3
- [ ] Implement file download from S3
- [ ] Implement file deletion from S3
- [ ] Update upload endpoint to use S3
- [ ] Add S3 configuration to environment
- [ ] Create file cleanup job

**Implementation**:
```python
# app/services/s3_service.py
import boto3
from botocore.exceptions import ClientError
from pathlib import Path
import logging
from typing import Optional
import os

logger = logging.getLogger("app")

class S3Service:
    def __init__(self):
        self.s3_client = boto3.client(
            's3',
            aws_access_key_id=os.getenv("AWS_ACCESS_KEY_ID"),
            aws_secret_access_key=os.getenv("AWS_SECRET_ACCESS_KEY"),
            region_name=os.getenv("AWS_REGION", "eu-central-1")
        )
        self.bucket_name = os.getenv("S3_BUCKET")
    
    async def upload_file(
        self,
        file_path: str,
        s3_key: str,
        content_type: Optional[str] = None
    ) -> str:
        """Upload file to S3"""
        try:
            extra_args = {}
            if content_type:
                extra_args['ContentType'] = content_type
            
            self.s3_client.upload_file(
                file_path,
                self.bucket_name,
                s3_key,
                ExtraArgs=extra_args
            )
            
            s3_url = f"s3://{self.bucket_name}/{s3_key}"
            logger.info(f"File uploaded to S3: {s3_url}")
            return s3_url
            
        except ClientError as e:
            logger.error(f"S3 upload failed: {str(e)}")
            raise Exception(f"Failed to upload file to S3: {str(e)}")
    
    async def download_file(self, s3_key: str, local_path: str):
        """Download file from S3"""
        try:
            self.s3_client.download_file(
                self.bucket_name,
                s3_key,
                local_path
            )
            logger.info(f"File downloaded from S3: {s3_key}")
        except ClientError as e:
            logger.error(f"S3 download failed: {str(e)}")
            raise Exception(f"Failed to download file from S3: {str(e)}")
    
    async def delete_file(self, s3_key: str):
        """Delete file from S3"""
        try:
            self.s3_client.delete_object(
                Bucket=self.bucket_name,
                Key=s3_key
            )
            logger.info(f"File deleted from S3: {s3_key}")
        except ClientError as e:
            logger.error(f"S3 deletion failed: {str(e)}")
            raise Exception(f"Failed to delete file from S3: {str(e)}")
    
    def generate_presigned_url(self, s3_key: str, expiration: int = 3600) -> str:
        """Generate presigned URL for temporary file access"""
        try:
            url = self.s3_client.generate_presigned_url(
                'get_object',
                Params={'Bucket': self.bucket_name, 'Key': s3_key},
                ExpiresIn=expiration
            )
            return url
        except ClientError as e:
            logger.error(f"Failed to generate presigned URL: {str(e)}")
            raise
```

**Success Criteria**:
- ✅ Files uploaded to S3
- ✅ Files can be downloaded
- ✅ Files can be deleted
- ✅ No local file storage dependency

---

#### 4.2 Environment Configuration & Validation ⭐ HIGH PRIORITY

**Task**: Add configuration validation and environment-specific configs

**Actions**:
- [ ] Create `app/core/config.py` using Pydantic Settings
- [ ] Validate all environment variables
- [ ] Add default values
- [ ] Create configuration schemas
- [ ] Add environment-specific configs (dev, staging, prod)

**Implementation**:
```python
# app/core/config.py
from pydantic_settings import BaseSettings
from pydantic import Field, validator
from typing import Optional

class Settings(BaseSettings):
    # Application
    APP_NAME: str = "Workshop Analytics API"
    APP_VERSION: str = "1.0.0"
    ENVIRONMENT: str = Field(default="development", env="ENVIRONMENT")
    DEBUG: bool = Field(default=False, env="DEBUG")
    
    # Database
    DB_HOST: str = Field(..., env="DB_HOST")
    DB_PORT: int = Field(default=3306, env="DB_PORT")
    DB_NAME: str = Field(..., env="DB_NAME")
    DB_USER: str = Field(..., env="DB_USER")
    DB_PASSWORD: str = Field(..., env="DB_PASSWORD")
    
    # AWS
    AWS_REGION: str = Field(default="eu-central-1", env="AWS_REGION")
    AWS_ACCESS_KEY_ID: Optional[str] = Field(None, env="AWS_ACCESS_KEY_ID")
    AWS_SECRET_ACCESS_KEY: Optional[str] = Field(None, env="AWS_SECRET_ACCESS_KEY")
    S3_BUCKET: Optional[str] = Field(None, env="S3_BUCKET")
    
    # Frontend
    FRONTEND_URL: str = Field(..., env="FRONTEND_URL")
    
    # File Upload
    MAX_FILE_SIZE: int = Field(default=10485760, env="MAX_FILE_SIZE")  # 10MB
    UPLOAD_DIR: str = Field(default="./uploads", env="UPLOAD_DIR")
    
    # Logging
    LOG_LEVEL: str = Field(default="INFO", env="LOG_LEVEL")
    
    # Firebase Authentication
    FIREBASE_SERVICE_ACCOUNT_PATH: Optional[str] = Field(None, env="FIREBASE_SERVICE_ACCOUNT_PATH")
    FIREBASE_PROJECT_ID: Optional[str] = Field(None, env="FIREBASE_PROJECT_ID")
    
    @validator("ENVIRONMENT")
    def validate_environment(cls, v):
        allowed = ["development", "staging", "production"]
        if v not in allowed:
            raise ValueError(f"ENVIRONMENT must be one of {allowed}")
        return v
    
    @validator("LOG_LEVEL")
    def validate_log_level(cls, v):
        allowed = ["DEBUG", "INFO", "WARNING", "ERROR", "CRITICAL"]
        if v not in allowed:
            raise ValueError(f"LOG_LEVEL must be one of {allowed}")
        return v
    
    class Config:
        env_file = ".env"
        case_sensitive = True

settings = Settings()
```

**Success Criteria**:
- ✅ All environment variables validated
- ✅ Configuration errors caught at startup
- ✅ Environment-specific configs working

---

## Phase 3: Security & Monitoring (Weeks 5-6)

### Week 5: Authentication System

#### 5.1 Firebase Authentication Implementation ⭐ CRITICAL

**Task**: Implement Firebase Authentication

**Actions**:
- [ ] Install Firebase Admin SDK: `pip install firebase-admin==6.3.0`
- [ ] Set up Firebase project and download service account key
- [ ] Initialize Firebase Admin SDK in backend
- [ ] Create token verification function
- [ ] Create authentication dependencies
- [ ] Add authentication to protected endpoints
- [ ] Create auth endpoints (verify token, get current user)
- [ ] Configure Firebase environment variables

**Files to Create**:
```
app/
├── core/
│   ├── firebase_auth.py      # Firebase Admin initialization & token verification
│   ├── auth_dependencies.py  # FastAPI dependencies for auth
│   └── authorization.py      # Role-based access control
└── api/v1/endpoints/
    └── auth.py               # Auth endpoints (verify, me)
```

**Detailed Implementation**: See `07_Authentication_System_Firebase.md` for complete guide

**Success Criteria**:
- ✅ Firebase Admin SDK initialized
- ✅ Token verification working
- ✅ Protected endpoints require Firebase ID token
- ✅ User information extracted from tokens
- ✅ Authentication endpoints functional

**Note**: Frontend authentication is handled by Firebase SDK. Backend only verifies tokens.

---

#### 5.2 Role-Based Access Control (RBAC) ⭐ CRITICAL

**Task**: Implement role-based permissions

**Actions**:
- [ ] Define user roles (admin, manager, operator, viewer)
- [ ] Create permission system
- [ ] Add role checks to endpoints
- [ ] Create permission decorators
- [ ] Update user model with roles

**Success Criteria**:
- ✅ Roles defined and enforced
- ✅ Permissions checked on each request
- ✅ Unauthorized access prevented

---

### Week 6: Rate Limiting & Security Hardening

#### 6.1 Rate Limiting ⭐ HIGH PRIORITY

**Task**: Implement rate limiting

**Actions**:
- [ ] Install slowapi: `pip install slowapi==0.1.9`
- [ ] Configure rate limits per endpoint
- [ ] Add rate limit middleware
- [ ] Set different limits for different endpoints
- [ ] Add rate limit headers to responses

**Success Criteria**:
- ✅ Rate limiting active
- ✅ Different limits per endpoint type
- ✅ Rate limit headers in responses

---

#### 6.2 Security Hardening ⭐ CRITICAL

**Task**: Implement additional security measures

**Actions**:
- [ ] Add HTTPS enforcement
- [ ] Fix CORS configuration (remove wildcards)
- [ ] Add security headers
- [ ] Implement CSRF protection
- [ ] Add request size limits
- [ ] Security audit

**Success Criteria**:
- ✅ All security measures implemented
- ✅ Security audit passed
- ✅ No critical vulnerabilities

---

## Phase 4: Testing & Documentation (Weeks 7-8)

### Week 7: Testing

#### 7.1 Unit Tests ⭐ HIGH PRIORITY

**Task**: Write comprehensive unit tests

**Actions**:
- [ ] Set up pytest configuration
- [ ] Create test database setup
- [ ] Write tests for CRUD operations
- [ ] Write tests for utilities
- [ ] Write tests for services
- [ ] Aim for 80%+ coverage

**Success Criteria**:
- ✅ Test coverage > 80%
- ✅ All tests passing
- ✅ CI/CD pipeline running tests

---

#### 7.2 Integration Tests ⭐ HIGH PRIORITY

**Task**: Write API integration tests

**Actions**:
- [ ] Test all API endpoints
- [ ] Test authentication flow
- [ ] Test file upload
- [ ] Test error scenarios
- [ ] Test pagination/filtering

**Success Criteria**:
- ✅ All endpoints tested
- ✅ Integration tests passing
- ✅ Edge cases covered

---

### Week 8: Documentation

#### 8.1 API Documentation ⭐ HIGH PRIORITY

**Task**: Complete API documentation

**Actions**:
- [ ] Complete OpenAPI/Swagger documentation
- [ ] Add detailed endpoint descriptions
- [ ] Add request/response examples
- [ ] Document error codes
- [ ] Create API usage guide

**Files to Create**:
```
docs/
├── API_Reference.md
├── Error_Codes.md
└── Authentication_Guide.md
```

**Success Criteria**:
- ✅ All endpoints documented
- ✅ Examples provided
- ✅ Error codes documented

---

#### 8.2 Additional Documentation ⭐ MEDIUM PRIORITY

**Task**: Create missing documentation

**Actions**:
- [ ] Database schema documentation
- [ ] Development setup guide
- [ ] Contributing guidelines
- [ ] Architecture decision records
- [ ] Deployment runbooks

**Files to Create**:
```
docs/
├── Database_Schema.md
├── Development_Setup.md
├── Contributing.md
├── Architecture_Decisions.md
└── Deployment_Runbook.md
```

**Success Criteria**:
- ✅ All documentation created
- ✅ Documentation complete and accurate
- ✅ Easy for new developers to onboard

---

## Implementation Checklist

### Phase 1: Critical Foundation ✅
- [ ] Database migrations (Alembic)
- [ ] Complete CRUD operations (GET by ID, UPDATE, DELETE)
- [ ] Error handling & logging
- [ ] Health check endpoints
- [ ] File upload security
- [ ] Scheduler error handling

### Phase 2: Production Features ✅
- [ ] Pagination
- [ ] Filtering & sorting
- [ ] Dashboard endpoints
- [ ] AWS S3 integration
- [ ] Configuration validation

### Phase 3: Security & Monitoring ✅
- [ ] JWT authentication
- [ ] Role-based access control
- [ ] Rate limiting
- [ ] Security hardening

### Phase 4: Testing & Documentation ✅
- [ ] Unit tests (80%+ coverage)
- [ ] Integration tests
- [ ] API documentation
- [ ] Additional documentation

---

## File Structure Changes

### Target Structure

```
backend/
├── app/
│   ├── __init__.py
│   ├── main.py
│   ├── core/
│   │   ├── __init__.py
│   │   ├── config.py              # NEW: Configuration
│   │   ├── security.py            # NEW: Auth utilities
│   │   ├── auth.py                # NEW: Auth dependencies
│   │   ├── exceptions.py          # NEW: Custom exceptions
│   │   ├── logger.py              # NEW: Logging setup
│   │   ├── middleware.py          # NEW: Custom middleware
│   │   ├── pagination.py          # NEW: Pagination utils
│   │   └── filters.py             # NEW: Filter utilities
│   ├── api/
│   │   └── v1/
│   │       ├── __init__.py
│   │       ├── api.py             # NEW: Router aggregation
│   │       └── endpoints/
│   │           ├── __init__.py
│   │           ├── machines.py    # NEW: Split from main.py
│   │           ├── templates.py   # NEW
│   │           ├── workorders.py  # NEW
│   │           ├── equipment.py   # NEW
│   │           ├── inspections.py # NEW
│   │           ├── employees.py   # NEW
│   │           ├── items.py       # NEW
│   │           ├── dashboard.py   # NEW
│   │           ├── auth.py        # NEW
│   │           └── health.py      # NEW
│   ├── models/
│   │   ├── user.py                # NEW: User model
│   │   └── (existing models)
│   ├── schemas/
│   │   ├── auth.py                # NEW: Auth schemas
│   │   ├── pagination.py          # NEW: Pagination schemas
│   │   └── (existing schemas + updates)
│   ├── crud/
│   │   └── (existing crud + updates)
│   ├── services/
│   │   ├── __init__.py
│   │   ├── s3_service.py          # NEW: S3 operations
│   │   └── analytics_service.py   # NEW: Analytics logic
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
├── scripts/
│   ├── migrate.py                 # NEW: Migration runner
│   └── seed.py                    # NEW: Database seeding
├── alembic.ini
├── requirements.txt
├── requirements-dev.txt
├── Dockerfile
└── .env.example
```

---

## Success Metrics

### Phase 1 Success
- ✅ All CRUD operations implemented
- ✅ Database migrations working
- ✅ Error handling comprehensive
- ✅ Logging active
- ✅ Health checks responding

### Phase 2 Success
- ✅ Pagination working
- ✅ Dashboard endpoints returning data
- ✅ S3 integration complete
- ✅ Configuration validated

### Phase 3 Success
- ✅ Authentication working
- ✅ Endpoints protected
- ✅ Rate limiting active
- ✅ Security audit passed

### Phase 4 Success
- ✅ Test coverage > 80%
- ✅ All documentation complete
- ✅ Ready for production

---

## Timeline Summary

| Phase | Duration | Focus | Priority |
|-------|----------|-------|----------|
| Phase 1 | Weeks 1-2 | Critical Foundation | 🔴 Critical |
| Phase 2 | Weeks 3-4 | Production Features | 🟠 High |
| Phase 3 | Weeks 5-6 | Security & Monitoring | 🔴 Critical |
| Phase 4 | Weeks 7-8 | Testing & Documentation | 🟡 Medium |

**Total Timeline**: 8 weeks

---

**Document Version**: 1.0  
**Created**: December 2024  
**Status**: Ready for Implementation

---

## Authentication Implementation

**Important**: This plan uses **Firebase Authentication** instead of custom JWT implementation.

For detailed Firebase Authentication setup and implementation guide, see:
- **`07_Authentication_System_Firebase.md`** - Complete Firebase auth guide

### Key Differences from Generic JWT:

1. **No Custom User Database**: Firebase manages users
2. **No Password Hashing**: Firebase handles password security
3. **No Token Generation**: Firebase generates ID tokens
4. **Token Verification**: Backend verifies tokens with Firebase Admin SDK
5. **Frontend Integration**: Flutter uses Firebase Auth SDK

### Phase 3 Authentication Tasks Reference:

- Backend: See `07_Authentication_System_Firebase.md` → Backend Implementation
- Frontend: See `07_Authentication_System_Firebase.md` → Frontend Implementation
- Setup: See `07_Authentication_System_Firebase.md` → Firebase Setup

