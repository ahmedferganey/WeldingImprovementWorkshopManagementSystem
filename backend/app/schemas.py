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
