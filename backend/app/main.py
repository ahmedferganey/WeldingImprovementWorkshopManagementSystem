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
