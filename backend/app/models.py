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
