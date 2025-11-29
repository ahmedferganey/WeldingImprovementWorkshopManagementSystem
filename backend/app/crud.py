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
