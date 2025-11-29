
# Welding Workshop Management System - Backend Documentation

##  Project Overview

This backend service is built with **FastAPI** and  **SQLAlchemy (async)** , using **MySQL** hosted on  **AWS RDS** . It supports:

* Machines, Templates, Workshop Entries
* Work Orders, Equipment, Inspections, Employees, Inventory Items
* Excel import for workshop entries
* Daily scheduled imports
* Fully async database operations
* AWS S3 integration for file uploads

---

##  Project Structure

```
backend/
├─ app/
│  ├─ main.py             # FastAPI application
│  ├─ models.py           # SQLAlchemy models
│  ├─ schemas.py          # Pydantic schemas
│  ├─ crud.py             # Async CRUD operations
│  ├─ database.py         # DB engine and session setup
│  ├─ utils.py            # Excel import helpers
│  ├─ scheduler.py        # APScheduler for daily imports
│  └─ storage/            # Optional S3-local sync folder
├─ aws/
│  ├─ deploy.sh           # Linux AWS deployment script
│  └─ deploy.ps1          # Windows AWS deployment script
├─ data/                  # Local test files
├─ .env                   # Environment variables
├─ Dockerfile
└─ requirements.txt
```

---

# Project layout (single-file view for this canvas). In a real project split into files shown below.

## docker-compose.yml

```yaml
services:
  backend:
    build: ./backend
    container_name: welding-backend
    ports:
      - "8000:8000"
    environment:
      AWS_REGION: ${AWS_REGION}
      AWS_ACCESS_KEY_ID: ${AWS_ACCESS_KEY_ID}
      AWS_SECRET_ACCESS_KEY: ${AWS_SECRET_ACCESS_KEY}
      S3_BUCKET: ${S3_BUCKET}
      DB_HOST: ${DB_HOST}
      DB_PORT: ${DB_PORT}
      DB_NAME: ${DB_NAME}
      DB_USER: ${DB_USER}
      DB_PASSWORD: ${DB_PASSWORD}
      FRONTEND_URL: ${FRONTEND_URL}
      DATA_DIR: ${DATA_DIR}
    volumes:
      - ./backend/uploads:/usr/src/backend/uploads
    logging:
      driver: "json-file"
      options:
        max-size: "10m"
        max-file: "3"
    restart: unless-stopped

```

## Dockerfile

```dockerfile
# -----------------------
# 1️⃣ Base image
# -----------------------
FROM python:3.11-slim

# Set environment variables
ENV PYTHONUNBUFFERED=1 \
    PYTHONDONTWRITEBYTECODE=1

# Working directory inside container
WORKDIR /usr/src/backend

# -----------------------
# 2️⃣ Copy requirements and install
# -----------------------
COPY requirements.txt .
RUN pip install --no-cache-dir --upgrade pip \
    && pip install --no-cache-dir -r requirements.txt

# -----------------------
# 3️⃣ Copy backend code
# -----------------------
COPY app ./app

# -----------------------
# 4️⃣ Create uploads directory
# -----------------------
RUN mkdir -p /usr/src/backend/uploads

# -----------------------
# 5️⃣ Expose FastAPI port
# -----------------------
EXPOSE 8000

# -----------------------
# 6️⃣ Run FastAPI
# -----------------------
CMD ["uvicorn", "app.main:app", "--host", "0.0.0.0", "--port", "8000"]

```

## requirements.txt

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

---

## app/database.py

```python
import os
from sqlalchemy.ext.asyncio import create_async_engine, AsyncSession
from sqlalchemy.orm import sessionmaker, declarative_base
from dotenv import load_dotenv

# Load .env variables
load_dotenv()

DB_USER = os.getenv("DB_USER")
DB_PASSWORD = os.getenv("DB_PASSWORD")
DB_HOST = os.getenv("DB_HOST")
DB_PORT = os.getenv("DB_PORT", "3306")
DB_NAME = os.getenv("DB_NAME")

# Async SQLAlchemy URL for AWS RDS MySQL
DATABASE_URL = f"mysql+aiomysql://{DB_USER}:{DB_PASSWORD}@{DB_HOST}:{DB_PORT}/{DB_NAME}"

# Async engine
engine = create_async_engine(DATABASE_URL, echo=True, future=True)

# Async session factory
AsyncSessionLocal = sessionmaker(
    bind=engine,
    class_=AsyncSession,
    expire_on_commit=False
)

# Base model
Base = declarative_base()

# FastAPI dependency
async def get_db():
    async with AsyncSessionLocal() as session:
        yield session

```

## app/models.py

```python
from sqlalchemy import Column, Integer, String, DateTime, ForeignKey, JSON, Text, Boolean
from sqlalchemy.orm import relationship
from sqlalchemy.sql import func
from .database import Base

# -----------------------------
# Machines
# -----------------------------
class Machine(Base):
    __tablename__ = "machines"

    id = Column(Integer, primary_key=True)
    name = Column(String(128), nullable=False)
    code = Column(String(64), unique=True, nullable=False)
    type = Column(String(64), nullable=True)
    metadata = Column(JSON, default=dict)

    templates = relationship("Template", back_populates="machine", cascade="all, delete-orphan")

# -----------------------------
# Templates
# -----------------------------
class Template(Base):
    __tablename__ = "templates"

    id = Column(Integer, primary_key=True)
    name = Column(String(128), nullable=False)
    description = Column(Text, nullable=True)
    machine_id = Column(Integer, ForeignKey("machines.id"), nullable=False)
    mapping = Column(JSON, nullable=False)
    active = Column(Boolean, default=True)

    machine = relationship("Machine", back_populates="templates")
    entries = relationship("WorkshopEntry", back_populates="template", cascade="all, delete-orphan")

# -----------------------------
# Workshop Entries
# -----------------------------
class WorkshopEntry(Base):
    __tablename__ = "workshop_entries"

    id = Column(Integer, primary_key=True)
    template_id = Column(Integer, ForeignKey("templates.id"), nullable=False)
    machine_id = Column(Integer, ForeignKey("machines.id"), nullable=False)
    imported_at = Column(DateTime(timezone=True), server_default=func.now())
    data = Column(JSON, nullable=False)

    template = relationship("Template", back_populates="entries")
    machine = relationship("Machine")

# -----------------------------
# Excel Imports
# -----------------------------
class ExcelImport(Base):
    __tablename__ = "excel_imports"

    id = Column(Integer, primary_key=True)
    filename = Column(String(256), nullable=False)
    template_id = Column(Integer, ForeignKey("templates.id"), nullable=False)
    scheduled_for = Column(DateTime(timezone=True))
    status = Column(String(32), default="pending")
    details = Column(JSON, default=dict)

# -----------------------------
# Work Orders
# -----------------------------
class WorkOrder(Base):
    __tablename__ = "work_orders"

    id = Column(Integer, primary_key=True, autoincrement=True)
    order_id = Column(String(32), unique=True, nullable=False)
    client = Column(String(128), nullable=False)
    description = Column(String(256))
    status = Column(String(32), default="Pending")
    due_date = Column(DateTime)
    assigned_welder = Column(String(128))

    inspections = relationship("Inspection", back_populates="work_order")

# -----------------------------
# Equipment
# -----------------------------
class Equipment(Base):
    __tablename__ = "equipment"

    id = Column(Integer, primary_key=True, autoincrement=True)
    equipment_id = Column(String(32), unique=True, nullable=False)
    name = Column(String(128), nullable=False)
    status = Column(String(32), default="Operational")
    last_service_date = Column(DateTime)

# -----------------------------
# Inspections / QC
# -----------------------------
class Inspection(Base):
    __tablename__ = "inspections"

    id = Column(Integer, primary_key=True, autoincrement=True)
    inspection_id = Column(String(32), unique=True, nullable=False)
    order_id = Column(String(32), ForeignKey("work_orders.order_id"))
    inspector = Column(String(128))
    result = Column(String(32))
    defect_type = Column(String(128), nullable=True)

    work_order = relationship("WorkOrder", back_populates="inspections")

# -----------------------------
# Employees
# -----------------------------
class Employee(Base):
    __tablename__ = "employees"

    id = Column(Integer, primary_key=True, autoincrement=True)
    employee_id = Column(String(32), unique=True, nullable=False)
    name = Column(String(128), nullable=False)
    role = Column(String(64))
    certification_expiry = Column(DateTime)

# -----------------------------
# Inventory / Items
# -----------------------------
class Item(Base):
    __tablename__ = "items"

    id = Column(Integer, primary_key=True, autoincrement=True)
    item_id = Column(String(32), unique=True, nullable=False)
    item_name = Column(String(128), nullable=False)
    quantity = Column(Integer, default=0)
    unit = Column(String(32))
    reorder_level = Column(Integer, default=0)

```

## app/schemas.py

```python
from pydantic import BaseModel
from typing import Optional, List, Dict, Any
from datetime import datetime

# -----------------------------
# Machine
# -----------------------------
class MachineBase(BaseModel):
    name: str
    code: str
    type: Optional[str]
    metadata: Optional[Dict[str, Any]] = {}

class MachineCreate(MachineBase):
    pass

class MachineOut(MachineBase):
    id: int

# -----------------------------
# Template
# -----------------------------
class TemplateBase(BaseModel):
    name: str
    description: Optional[str]
    machine_id: int
    mapping: Dict[str, str]

class TemplateCreate(TemplateBase):
    pass

class TemplateOut(TemplateBase):
    id: int

# -----------------------------
# Workshop Entry
# -----------------------------
class WorkshopEntryOut(BaseModel):
    id: int
    template_id: int
    machine_id: int
    imported_at: datetime
    data: Dict[str, Any]

# -----------------------------
# Excel Import
# -----------------------------
class ExcelImportOut(BaseModel):
    id: int
    filename: str
    template_id: int
    scheduled_for: Optional[datetime]
    status: str
    details: Optional[Dict[str, Any]] = {}

# -----------------------------
# Work Orders
# -----------------------------
class WorkOrderBase(BaseModel):
    order_id: str
    client: str
    description: Optional[str]
    status: Optional[str]
    due_date: Optional[datetime]
    assigned_welder: Optional[str]

class WorkOrderCreate(WorkOrderBase):
    pass

class WorkOrderOut(WorkOrderBase):
    id: int
    inspections: Optional[List["InspectionOut"]] = []

# -----------------------------
# Equipment
# -----------------------------
class EquipmentBase(BaseModel):
    equipment_id: str
    name: str
    status: Optional[str]
    last_service_date: Optional[datetime]

class EquipmentCreate(EquipmentBase):
    pass

class EquipmentOut(EquipmentBase):
    id: int

# -----------------------------
# Inspection
# -----------------------------
class InspectionBase(BaseModel):
    inspection_id: str
    order_id: str
    inspector: str
    result: str
    defect_type: Optional[str]

class InspectionCreate(InspectionBase):
    pass

class InspectionOut(InspectionBase):
    id: int

# -----------------------------
# Employee
# -----------------------------
class EmployeeBase(BaseModel):
    employee_id: str
    name: str
    role: Optional[str]
    certification_expiry: Optional[datetime]

class EmployeeCreate(EmployeeBase):
    pass

class EmployeeOut(EmployeeBase):
    id: int

# -----------------------------
# Item / Inventory
# -----------------------------
class ItemBase(BaseModel):
    item_id: str
    item_name: str
    quantity: Optional[int]
    unit: Optional[str]
    reorder_level: Optional[int]

class ItemCreate(ItemBase):
    pass

class ItemOut(ItemBase):
    id: int

```

## app/crud.py

```python
from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession
from .models import (
    Machine, Template, WorkshopEntry, ExcelImport,
    WorkOrder, Equipment, Inspection, Employee, Item
)
from .schemas import (
    MachineCreate, TemplateCreate, WorkOrderCreate,
    EquipmentCreate, InspectionCreate, EmployeeCreate, ItemCreate
)

# -----------------------------
# Machines
# -----------------------------
async def create_machine(db: AsyncSession, obj: MachineCreate):
    m = Machine(**obj.model_dump())
    db.add(m)
    await db.commit()
    await db.refresh(m)
    return m

async def list_machines(db: AsyncSession):
    q = await db.execute(select(Machine))
    return q.scalars().all()

# -----------------------------
# Templates
# -----------------------------
async def create_template(db: AsyncSession, obj: TemplateCreate):
    t = Template(**obj.model_dump())
    db.add(t)
    await db.commit()
    await db.refresh(t)
    return t

async def list_templates(db: AsyncSession):
    q = await db.execute(select(Template))
    return q.scalars().all()

# -----------------------------
# Work Orders
# -----------------------------
async def create_work_order(db: AsyncSession, obj: WorkOrderCreate):
    wo = WorkOrder(**obj.model_dump())
    db.add(wo)
    await db.commit()
    await db.refresh(wo)
    return wo

async def list_work_orders(db: AsyncSession):
    q = await db.execute(select(WorkOrder))
    return q.scalars().all()

# -----------------------------
# Equipment
# -----------------------------
async def create_equipment(db: AsyncSession, obj: EquipmentCreate):
    eq = Equipment(**obj.model_dump())
    db.add(eq)
    await db.commit()
    await db.refresh(eq)
    return eq

async def list_equipment(db: AsyncSession):
    q = await db.execute(select(Equipment))
    return q.scalars().all()

# -----------------------------
# Inspections
# -----------------------------
async def create_inspection(db: AsyncSession, obj: InspectionCreate):
    ins = Inspection(**obj.model_dump())
    db.add(ins)
    await db.commit()
    await db.refresh(ins)
    return ins

async def list_inspections(db: AsyncSession):
    q = await db.execute(select(Inspection))
    return q.scalars().all()

# -----------------------------
# Employees
# -----------------------------
async def create_employee(db: AsyncSession, obj: EmployeeCreate):
    emp = Employee(**obj.model_dump())
    db.add(emp)
    await db.commit()
    await db.refresh(emp)
    return emp

async def list_employees(db: AsyncSession):
    q = await db.execute(select(Employee))
    return q.scalars().all()

# -----------------------------
# Inventory Items
# -----------------------------
async def create_item(db: AsyncSession, obj: ItemCreate):
    item = Item(**obj.model_dump())
    db.add(item)
    await db.commit()
    await db.refresh(item)
    return item

async def list_items(db: AsyncSession):
    q = await db.execute(select(Item))
    return q.scalars().all()

```

## app/utils.py

```python
import pandas as pd
from typing import Dict, Any, List

def import_excel_to_entries(filepath: str, mapping: Dict[str, str]) -> List[Dict[str, Any]]:
    """
    Reads an Excel file and converts rows to WorkshopEntry data
    `mapping` example: {"Sheet Column Name": "field_name"}
    """
    df = pd.read_excel(filepath)
    entries = []
    for _, row in df.iterrows():
        data = {}
        for col, field in mapping.items():
            data[field] = None if pd.isna(row.get(col)) else row.get(col)
        entries.append(data)
    return entries

```

## app/scheduler.py

```python
from apscheduler.schedulers.asyncio import AsyncIOScheduler
from apscheduler.triggers.cron import CronTrigger
from .utils import import_excel_to_entries
from .models import WorkshopEntry, Template
from .database import AsyncSessionLocal

scheduler = AsyncIOScheduler()

async def run_import_job(filepath: str, template_id: int):
    async with AsyncSessionLocal() as session:
        tpl = await session.get(Template, template_id)
        if not tpl:
            return
        entries = import_excel_to_entries(filepath, tpl.mapping)
        for data in entries:
            we = WorkshopEntry(template_id=template_id, machine_id=tpl.machine_id, data=data)
            session.add(we)
        await session.commit()

def schedule_daily_import(job_id: str, hour: int, minute: int, filepath: str, template_id: int, db_factory=None):
    trigger = CronTrigger(hour=hour, minute=minute)
    scheduler.add_job(run_import_job, trigger, args=(filepath, template_id), id=job_id, replace_existing=True)

def start_scheduler():
    scheduler.start()

```

## app/main.py

```python
import uuid
from pathlib import Path
from fastapi import FastAPI, UploadFile, File, Depends, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from sqlalchemy.ext.asyncio import AsyncSession
from .database import Base, engine, get_db
from . import models, crud, utils, scheduler
from .schemas import (
    MachineCreate, TemplateCreate, WorkOrderCreate,
    EquipmentCreate, InspectionCreate, EmployeeCreate, ItemCreate
)

app = FastAPI(title="Workshop Analytics API")

# CORS
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

# Startup: create tables (dev only)
@app.on_event("startup")
async def on_start():
    async with engine.begin() as conn:
        await conn.run_sync(Base.metadata.create_all)
    scheduler.start_scheduler()

# -----------------------------
# File Upload
# -----------------------------
@app.post("/upload/{template_id}")
async def upload_excel(template_id: int, file: UploadFile = File(...), db: AsyncSession = Depends(get_db)):
    uploads_dir = Path("./uploads")
    uploads_dir.mkdir(parents=True, exist_ok=True)
    filename = f"{uuid.uuid4()}_{file.filename}"
    filepath = uploads_dir / filename
    with open(filepath, "wb") as f:
        f.write(await file.read())
    tpl = await db.get(models.Template, template_id)
    if not tpl:
        raise HTTPException(404, "Template not found")
    entries = utils.import_excel_to_entries(str(filepath), tpl.mapping)
    for data in entries:
        we = models.WorkshopEntry(template_id=template_id, machine_id=tpl.machine_id, data=data)
        db.add(we)
    await db.commit()
    return {"imported": len(entries)}

# -----------------------------
# Schedule daily import
# -----------------------------
@app.post("/schedule/import/{template_id}")
async def schedule_import(template_id: int, hour: int = 2, minute: int = 0, path: str = None):
    if path is None:
        raise HTTPException(400, "path to excel file required")
    job_id = f"import_{template_id}_{hour}_{minute}"
    scheduler.schedule_daily_import(job_id, hour, minute, path, template_id, None)
    return {"scheduled": job_id}

# -----------------------------
# CRUD Endpoints
# -----------------------------
@app.post("/machines")
async def create_machine_endpoint(body: MachineCreate, db: AsyncSession = Depends(get_db)):
    return await crud.create_machine(db, body)

@app.get("/machines")
async def list_machines_endpoint(db: AsyncSession = Depends(get_db)):
    return await crud.list_machines(db)

@app.post("/templates")
async def create_template_endpoint(body: TemplateCreate, db: AsyncSession = Depends(get_db)):
    return await crud.create_template(db, body)

@app.get("/templates")
async def list_templates_endpoint(db: AsyncSession = Depends(get_db)):
    return await crud.list_templates(db)

@app.post("/workorders")
async def create_workorder_endpoint(body: WorkOrderCreate, db: AsyncSession = Depends(get_db)):
    return await crud.create_work_order(db, body)

@app.get("/workorders")
async def list_workorders_endpoint(db: AsyncSession = Depends(get_db)):
    return await crud.list_work_orders(db)

@app.post("/equipment")
async def create_equipment_endpoint(body: EquipmentCreate, db: AsyncSession = Depends(get_db)):
    return await crud.create_equipment(db, body)

@app.get("/equipment")
async def list_equipment_endpoint(db: AsyncSession = Depends(get_db)):
    return await crud.list_equipment(db)

@app.post("/inspections")
async def create_inspection_endpoint(body: InspectionCreate, db: AsyncSession = Depends(get_db)):
    return await crud.create_inspection(db, body)

@app.get("/inspections")
async def list_inspections_endpoint(db: AsyncSession = Depends(get_db)):
    return await crud.list_inspections(db)

@app.post("/employees")
async def create_employee_endpoint(body: EmployeeCreate, db: AsyncSession = Depends(get_db)):
    return await crud.create_employee(db, body)

@app.get("/employees")
async def list_employees_endpoint(db: AsyncSession = Depends(get_db)):
    return await crud.list_employees(db)

@app.post("/items")
async def create_item_endpoint(body: ItemCreate, db: AsyncSession = Depends(get_db)):
    return await crud.create_item(db, body)

@app.get("/items")
async def list_items_endpoint(db: AsyncSession = Depends(get_db)):
    return await crud.list_items(db)

```
## app/schemas.py


```python
from pydantic import BaseModel
from typing import Optional, List, Dict, Any
from datetime import datetime

# -----------------------------
# Machine
# -----------------------------
class MachineBase(BaseModel):
    name: str
    code: str
    type: Optional[str]
    metadata: Optional[Dict[str, Any]] = {}

class MachineCreate(MachineBase):
    pass

class MachineOut(MachineBase):
    id: int

# -----------------------------
# Template
# -----------------------------
class TemplateBase(BaseModel):
    name: str
    description: Optional[str]
    machine_id: int
    mapping: Dict[str, str]

class TemplateCreate(TemplateBase):
    pass

class TemplateOut(TemplateBase):
    id: int

# -----------------------------
# Workshop Entry
# -----------------------------
class WorkshopEntryOut(BaseModel):
    id: int
    template_id: int
    machine_id: int
    imported_at: datetime
    data: Dict[str, Any]

# -----------------------------
# Excel Import
# -----------------------------
class ExcelImportOut(BaseModel):
    id: int
    filename: str
    template_id: int
    scheduled_for: Optional[datetime]
    status: str
    details: Optional[Dict[str, Any]] = {}

# -----------------------------
# Work Orders
# -----------------------------
class WorkOrderBase(BaseModel):
    order_id: str
    client: str
    description: Optional[str]
    status: Optional[str]
    due_date: Optional[datetime]
    assigned_welder: Optional[str]

class WorkOrderCreate(WorkOrderBase):
    pass

class WorkOrderOut(WorkOrderBase):
    id: int
    inspections: Optional[List["InspectionOut"]] = []

# -----------------------------
# Equipment
# -----------------------------
class EquipmentBase(BaseModel):
    equipment_id: str
    name: str
    status: Optional[str]
    last_service_date: Optional[datetime]

class EquipmentCreate(EquipmentBase):
    pass

class EquipmentOut(EquipmentBase):
    id: int

# -----------------------------
# Inspection
# -----------------------------
class InspectionBase(BaseModel):
    inspection_id: str
    order_id: str
    inspector: str
    result: str
    defect_type: Optional[str]

class InspectionCreate(InspectionBase):
    pass

class InspectionOut(InspectionBase):
    id: int

# -----------------------------
# Employee
# -----------------------------
class EmployeeBase(BaseModel):
    employee_id: str
    name: str
    role: Optional[str]
    certification_expiry: Optional[datetime]

class EmployeeCreate(EmployeeBase):
    pass

class EmployeeOut(EmployeeBase):
    id: int

# -----------------------------
# Item / Inventory
# -----------------------------
class ItemBase(BaseModel):
    item_id: str
    item_name: str
    quantity: Optional[int]
    unit: Optional[str]
    reorder_level: Optional[int]

class ItemCreate(ItemBase):
    pass

class ItemOut(ItemBase):
    id: int


```

## aws/deploy.ps1


```powershell

# Move to backend root
Set-Location (Split-Path $MyInvocation.MyCommand.Path -Parent)\..

# -------------------
# CONFIG VARIABLES
# -------------------
$AWS_REGION = "eu-central-1"
$IAM_USER = "workshop-deployer"
$S3_BUCKET = "workshop-uploads-$(Get-Date -UFormat %s)"
$DB_INSTANCE = "workshop-db"
$DB_NAME = "workshop"
$DB_USERNAME = "workshop"
$DB_PASSWORD = "StrongPasswordHere"
$DB_CLASS = "db.t3.micro"
$DB_SUBNET_GROUP = "workshop-subnets"
$VPC_SG = "sg-xxxxxx"           # Replace with your security group ID
$SUBNETS = "subnet-abc subnet-def"  # Replace with your subnet IDs

# -------------------
# 1️⃣ CREATE IAM USER
# -------------------
Write-Host "Creating IAM user: $IAM_USER"
try { aws iam create-user --user-name $IAM_USER } catch { Write-Host "User may already exist" }

# Check existing keys
$existingKeys = aws iam list-access-keys --user-name $IAM_USER | ConvertFrom-Json
if ($existingKeys.AccessKeyMetadata.Count -eq 0) {
    Write-Host "Creating new access keys..."
    $creds = aws iam create-access-key --user-name $IAM_USER | ConvertFrom-Json
} else {
    Write-Host "Using existing access keys (secret must be retrieved manually)"
    $creds = $existingKeys.AccessKeyMetadata[0]
    $creds.SecretAccessKey = "PLEASE_RETRIEVE_SECRET_FROM_AWS"
}

$ACCESS_KEY = $creds.AccessKeyId
$SECRET_KEY = $creds.SecretAccessKey

# Attach policies
$policies = @(
    "arn:aws:iam::aws:policy/AmazonS3FullAccess",
    "arn:aws:iam::aws:policy/AmazonRDSFullAccess",
    "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryFullAccess",
    "arn:aws:iam::aws:policy/AWSElasticBeanstalkFullAccess",
    "arn:aws:iam::aws:policy/SecretsManagerReadWrite"
)
foreach ($policy in $policies) {
    try { aws iam attach-user-policy --user-name $IAM_USER --policy-arn $policy } catch {}
}

# -------------------
# 2️⃣ CREATE S3 BUCKET
# -------------------
Write-Host "Creating S3 bucket: $S3_BUCKET"
try { aws s3api create-bucket --bucket $S3_BUCKET --region $AWS_REGION --create-bucket-configuration LocationConstraint=$AWS_REGION } catch { Write-Host "Bucket may exist" }

# -------------------
# 3️⃣ CREATE DB SUBNET GROUP
# -------------------
Write-Host "Creating DB subnet group: $DB_SUBNET_GROUP"
try { aws rds describe-db-subnet-groups --db-subnet-group-name $DB_SUBNET_GROUP } catch {
    aws rds create-db-subnet-group --db-subnet-group-name $DB_SUBNET_GROUP --db-subnet-group-description "Workshop DB subnets" --subnet-ids $SUBNETS
}

# -------------------
# 4️⃣ CREATE RDS INSTANCE
# -------------------
Write-Host "Creating RDS instance: $DB_INSTANCE"
try { aws rds describe-db-instances --db-instance-identifier $DB_INSTANCE } catch {
    aws rds create-db-instance `
        --db-instance-identifier $DB_INSTANCE `
        --allocated-storage 20 `
        --db-instance-class $DB_CLASS `
        --engine mysql `
        --engine-version 8.0.34 `
        --master-username $DB_USERNAME `
        --master-user-password $DB_PASSWORD `
        --backup-retention-period 7 `
        --db-name $DB_NAME `
        --vpc-security-group-ids $VPC_SG `
        --db-subnet-group-name $DB_SUBNET_GROUP `
        --publicly-accessible $false
}

Write-Host "Waiting for RDS to become available..."
aws rds wait db-instance-available --db-instance-identifier $DB_INSTANCE
Write-Host "RDS instance is ready!"

# -------------------
# 5️⃣ GENERATE .ENV
# -------------------
$DB_HOST = aws rds describe-db-instances --db-instance-identifier $DB_INSTANCE --query "DBInstances[0].Endpoint.Address" --output text

$envContent = @"
AWS_REGION=$AWS_REGION
AWS_ACCESS_KEY_ID=$ACCESS_KEY
AWS_SECRET_ACCESS_KEY=$SECRET_KEY
S3_BUCKET=$S3_BUCKET
DB_HOST=$DB_HOST
DB_PORT=3306
DB_NAME=$DB_NAME
DB_USER=$DB_USERNAME
DB_PASSWORD=$DB_PASSWORD
FRONTEND_URL=https://weldingworkshop-f4697.web.app/
"@

$envContent | Out-File -FilePath ".env" -Encoding ascii
Write-Host ".env file created successfully in backend/"
```
---

##  REST Endpoints

* `/machines` – GET / POST
* `/templates` – GET / POST
* `/workorders` – GET / POST
* `/equipment` – GET / POST
* `/inspections` – GET / POST
* `/employees` – GET / POST
* `/items` – GET / POST
* `/upload/{template_id}` – Upload Excel file
* `/schedule/import/{template_id}` – Schedule daily import
