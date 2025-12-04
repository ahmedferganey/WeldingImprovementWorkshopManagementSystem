# API Specification

**Project**: Welding Improvement Workshop Management System  
**API Version**: v1  
**Base URL**: `https://welding-backend-v1-0.onrender.com` (Production)  
**Local URL**: `http://localhost:8000` (Development)  
**Last Updated**: December 2024

---

## Table of Contents

1. [Authentication](#authentication)
2. [Common Patterns](#common-patterns)
3. [Error Handling](#error-handling)
4. [Machines API](#machines-api)
5. [Templates API](#templates-api)
6. [Work Orders API](#work-orders-api)
7. [Equipment API](#equipment-api)
8. [Inspections API](#inspections-api)
9. [Employees API](#employees-api)
10. [Items API](#items-api)
11. [Dashboard API](#dashboard-api)
12. [File Upload API](#file-upload-api)
13. [Scheduling API](#scheduling-api)
14. [Health Check API](#health-check-api)

---

## Authentication

**Status**: ⚠️ Not implemented (to be added in Phase 3)

### Planned Implementation

All endpoints (except public ones) will require authentication via JWT tokens.

**Header Format**:
```
Authorization: Bearer <jwt_token>
```

**Login Endpoint** (To be implemented):
```
POST /auth/login
Content-Type: application/json

{
  "username": "user@example.com",
  "password": "password123"
}

Response:
{
  "access_token": "eyJhbGciOiJIUzI1NiIs...",
  "token_type": "bearer",
  "expires_in": 3600
}
```

---

## Common Patterns

### Pagination

All list endpoints will support pagination (to be implemented).

**Query Parameters**:
- `skip` (integer, default: 0) - Number of records to skip
- `limit` (integer, default: 100, max: 1000) - Number of records to return

**Response Format**:
```json
{
  "items": [...],
  "total": 150,
  "skip": 0,
  "limit": 50,
  "has_more": true
}
```

### Filtering

**Query Parameters** (resource-specific):
- `status` - Filter by status
- `created_from` - Filter by creation date (from)
- `created_to` - Filter by creation date (to)

### Sorting

**Query Parameters**:
- `sort_by` - Field to sort by
- `order` - Sort order: `asc` or `desc`

---

## Error Handling

### Error Response Format

```json
{
  "detail": "Error message description",
  "error_code": "ERROR_CODE",
  "timestamp": "2024-12-01T12:00:00Z"
}
```

### HTTP Status Codes

| Code | Meaning | Description |
|------|---------|-------------|
| 200 | OK | Request successful |
| 201 | Created | Resource created successfully |
| 400 | Bad Request | Invalid request parameters |
| 401 | Unauthorized | Authentication required |
| 403 | Forbidden | Insufficient permissions |
| 404 | Not Found | Resource not found |
| 409 | Conflict | Resource conflict (e.g., duplicate) |
| 422 | Unprocessable Entity | Validation error |
| 500 | Internal Server Error | Server error |

### Common Error Codes

- `VALIDATION_ERROR` - Request validation failed
- `NOT_FOUND` - Resource not found
- `DUPLICATE_RESOURCE` - Resource already exists
- `UNAUTHORIZED` - Authentication required
- `FORBIDDEN` - Insufficient permissions
- `SERVER_ERROR` - Internal server error

---

## Machines API

### List Machines

**Endpoint**: `GET /machines`

**Status**: ✅ Implemented

**Query Parameters** (to be added):
- `skip` (integer, optional)
- `limit` (integer, optional)
- `type` (string, optional) - Filter by machine type

**Response**: `200 OK`
```json
[
  {
    "id": 1,
    "name": "Welding Machine A",
    "code": "WM-001",
    "type": "MIG",
    "metadata": {}
  }
]
```

---

### Get Machine by ID

**Endpoint**: `GET /machines/{machine_id}`

**Status**: ❌ Not implemented (planned for Phase 1)

**Path Parameters**:
- `machine_id` (integer, required) - Machine ID

**Response**: `200 OK`
```json
{
  "id": 1,
  "name": "Welding Machine A",
  "code": "WM-001",
  "type": "MIG",
  "metadata": {}
}
```

**Error Responses**:
- `404 Not Found` - Machine not found

---

### Create Machine

**Endpoint**: `POST /machines`

**Status**: ✅ Implemented

**Request Body**:
```json
{
  "name": "Welding Machine A",
  "code": "WM-001",
  "type": "MIG",
  "metadata": {}
}
```

**Response**: `201 Created`
```json
{
  "id": 1,
  "name": "Welding Machine A",
  "code": "WM-001",
  "type": "MIG",
  "metadata": {}
}
```

**Error Responses**:
- `400 Bad Request` - Invalid request body
- `409 Conflict` - Machine with code already exists

---

### Update Machine

**Endpoint**: `PUT /machines/{machine_id}`

**Status**: ❌ Not implemented (planned for Phase 1)

**Path Parameters**:
- `machine_id` (integer, required)

**Request Body**:
```json
{
  "name": "Welding Machine A Updated",
  "code": "WM-001",
  "type": "TIG",
  "metadata": {"location": "Workshop 1"}
}
```

**Response**: `200 OK`
```json
{
  "id": 1,
  "name": "Welding Machine A Updated",
  "code": "WM-001",
  "type": "TIG",
  "metadata": {"location": "Workshop 1"}
}
```

---

### Partial Update Machine

**Endpoint**: `PATCH /machines/{machine_id}`

**Status**: ❌ Not implemented (planned for Phase 1)

**Request Body** (partial):
```json
{
  "type": "TIG"
}
```

**Response**: `200 OK`
```json
{
  "id": 1,
  "name": "Welding Machine A",
  "code": "WM-001",
  "type": "TIG",
  "metadata": {}
}
```

---

### Delete Machine

**Endpoint**: `DELETE /machines/{machine_id}`

**Status**: ❌ Not implemented (planned for Phase 1)

**Response**: `200 OK`
```json
{
  "message": "Machine deleted successfully"
}
```

**Error Responses**:
- `404 Not Found` - Machine not found
- `409 Conflict` - Machine has associated templates

---

## Templates API

### List Templates

**Endpoint**: `GET /templates`

**Status**: ✅ Implemented

**Query Parameters** (to be added):
- `machine_id` (integer, optional) - Filter by machine
- `active` (boolean, optional) - Filter by active status

**Response**: `200 OK`
```json
[
  {
    "id": 1,
    "name": "Daily Import Template",
    "description": "Import daily welding data",
    "machine_id": 1,
    "mapping": {
      "Order ID": "order_id",
      "Client": "client"
    },
    "active": true
  }
]
```

---

### Get Template by ID

**Endpoint**: `GET /templates/{template_id}`

**Status**: ❌ Not implemented

**Response**: `200 OK`
```json
{
  "id": 1,
  "name": "Daily Import Template",
  "description": "Import daily welding data",
  "machine_id": 1,
  "mapping": {
    "Order ID": "order_id",
    "Client": "client"
  },
  "active": true
}
```

---

### Create Template

**Endpoint**: `POST /templates`

**Status**: ✅ Implemented

**Request Body**:
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

**Response**: `201 Created`
```json
{
  "id": 1,
  "name": "Daily Import Template",
  "description": "Import daily welding data",
  "machine_id": 1,
  "mapping": {
    "Order ID": "order_id",
    "Client": "client"
  },
  "active": true
}
```

---

### Update Template

**Endpoint**: `PUT /templates/{template_id}`

**Status**: ❌ Not implemented

---

### Delete Template

**Endpoint**: `DELETE /templates/{template_id}`

**Status**: ❌ Not implemented

---

## Work Orders API

### List Work Orders

**Endpoint**: `GET /workorders`

**Status**: ✅ Implemented

**Query Parameters** (to be added):
- `status` (string, optional) - Filter by status
- `client` (string, optional) - Filter by client
- `assigned_welder` (string, optional) - Filter by welder
- `due_from` (datetime, optional) - Filter by due date (from)
- `due_to` (datetime, optional) - Filter by due date (to)

**Response**: `200 OK`
```json
[
  {
    "id": 1,
    "order_id": "WO-2024-001",
    "client": "ABC Corp",
    "description": "Steel frame welding",
    "status": "Pending",
    "due_date": "2024-12-31T23:59:59",
    "assigned_welder": "John Doe",
    "inspections": []
  }
]
```

---

### Get Work Order by ID

**Endpoint**: `GET /workorders/{workorder_id}`

**Status**: ❌ Not implemented

**Response**: `200 OK`
```json
{
  "id": 1,
  "order_id": "WO-2024-001",
  "client": "ABC Corp",
  "description": "Steel frame welding",
  "status": "Pending",
  "due_date": "2024-12-31T23:59:59",
  "assigned_welder": "John Doe",
  "inspections": [
    {
      "id": 1,
      "inspection_id": "INS-001",
      "order_id": "WO-2024-001",
      "inspector": "Jane Smith",
      "result": "Pass",
      "defect_type": null
    }
  ]
}
```

---

### Create Work Order

**Endpoint**: `POST /workorders`

**Status**: ✅ Implemented

**Request Body**:
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

**Response**: `201 Created`
```json
{
  "id": 1,
  "order_id": "WO-2024-001",
  "client": "ABC Corp",
  "description": "Steel frame welding",
  "status": "Pending",
  "due_date": "2024-12-31T23:59:59",
  "assigned_welder": "John Doe"
}
```

**Error Responses**:
- `409 Conflict` - Work order with order_id already exists

---

### Update Work Order

**Endpoint**: `PUT /workorders/{workorder_id}`

**Status**: ❌ Not implemented

---

### Delete Work Order

**Endpoint**: `DELETE /workorders/{workorder_id}`

**Status**: ❌ Not implemented

---

## Equipment API

### List Equipment

**Endpoint**: `GET /equipment`

**Status**: ✅ Implemented

**Query Parameters** (to be added):
- `status` (string, optional) - Filter by status

**Response**: `200 OK`
```json
[
  {
    "id": 1,
    "equipment_id": "EQ-001",
    "name": "MIG Welder",
    "status": "Operational",
    "last_service_date": "2024-11-01T00:00:00"
  }
]
```

---

### Get Equipment by ID

**Endpoint**: `GET /equipment/{equipment_id}`

**Status**: ❌ Not implemented

---

### Create Equipment

**Endpoint**: `POST /equipment`

**Status**: ✅ Implemented

**Request Body**:
```json
{
  "equipment_id": "EQ-001",
  "name": "MIG Welder",
  "status": "Operational",
  "last_service_date": "2024-11-01T00:00:00"
}
```

**Response**: `201 Created`
```json
{
  "id": 1,
  "equipment_id": "EQ-001",
  "name": "MIG Welder",
  "status": "Operational",
  "last_service_date": "2024-11-01T00:00:00"
}
```

---

### Update Equipment

**Endpoint**: `PUT /equipment/{equipment_id}`

**Status**: ❌ Not implemented

---

### Delete Equipment

**Endpoint**: `DELETE /equipment/{equipment_id}`

**Status**: ❌ Not implemented

---

## Inspections API

### List Inspections

**Endpoint**: `GET /inspections`

**Status**: ✅ Implemented

**Query Parameters** (to be added):
- `order_id` (string, optional) - Filter by work order
- `result` (string, optional) - Filter by result (Pass/Fail)
- `inspector` (string, optional) - Filter by inspector

**Response**: `200 OK`
```json
[
  {
    "id": 1,
    "inspection_id": "INS-001",
    "order_id": "WO-2024-001",
    "inspector": "Jane Smith",
    "result": "Pass",
    "defect_type": null
  }
]
```

---

### Get Inspection by ID

**Endpoint**: `GET /inspections/{inspection_id}`

**Status**: ❌ Not implemented

---

### Create Inspection

**Endpoint**: `POST /inspections`

**Status**: ✅ Implemented

**Request Body**:
```json
{
  "inspection_id": "INS-001",
  "order_id": "WO-2024-001",
  "inspector": "Jane Smith",
  "result": "Pass",
  "defect_type": null
}
```

**Response**: `201 Created`
```json
{
  "id": 1,
  "inspection_id": "INS-001",
  "order_id": "WO-2024-001",
  "inspector": "Jane Smith",
  "result": "Pass",
  "defect_type": null
}
```

---

### Update Inspection

**Endpoint**: `PUT /inspections/{inspection_id}`

**Status**: ❌ Not implemented

---

### Delete Inspection

**Endpoint**: `DELETE /inspections/{inspection_id}`

**Status**: ❌ Not implemented

---

## Employees API

### List Employees

**Endpoint**: `GET /employees`

**Status**: ✅ Implemented

**Query Parameters** (to be added):
- `role` (string, optional) - Filter by role

**Response**: `200 OK`
```json
[
  {
    "id": 1,
    "employee_id": "EMP-001",
    "name": "John Doe",
    "role": "Welder",
    "certification_expiry": "2025-12-31T23:59:59"
  }
]
```

---

### Get Employee by ID

**Endpoint**: `GET /employees/{employee_id}`

**Status**: ❌ Not implemented

---

### Create Employee

**Endpoint**: `POST /employees`

**Status**: ✅ Implemented

**Request Body**:
```json
{
  "employee_id": "EMP-001",
  "name": "John Doe",
  "role": "Welder",
  "certification_expiry": "2025-12-31T23:59:59"
}
```

**Response**: `201 Created`
```json
{
  "id": 1,
  "employee_id": "EMP-001",
  "name": "John Doe",
  "role": "Welder",
  "certification_expiry": "2025-12-31T23:59:59"
}
```

---

### Update Employee

**Endpoint**: `PUT /employees/{employee_id}`

**Status**: ❌ Not implemented

---

### Delete Employee

**Endpoint**: `DELETE /employees/{employee_id}`

**Status**: ❌ Not implemented

---

## Items API

### List Items

**Endpoint**: `GET /items`

**Status**: ✅ Implemented

**Query Parameters** (to be added):
- `low_stock` (boolean, optional) - Filter low stock items

**Response**: `200 OK`
```json
[
  {
    "id": 1,
    "item_id": "ITM-001",
    "item_name": "Steel Rods",
    "quantity": 100,
    "unit": "kg",
    "reorder_level": 20
  }
]
```

---

### Get Item by ID

**Endpoint**: `GET /items/{item_id}`

**Status**: ❌ Not implemented

---

### Create Item

**Endpoint**: `POST /items`

**Status**: ✅ Implemented

**Request Body**:
```json
{
  "item_id": "ITM-001",
  "item_name": "Steel Rods",
  "quantity": 100,
  "unit": "kg",
  "reorder_level": 20
}
```

**Response**: `201 Created`
```json
{
  "id": 1,
  "item_id": "ITM-001",
  "item_name": "Steel Rods",
  "quantity": 100,
  "unit": "kg",
  "reorder_level": 20
}
```

---

### Update Item

**Endpoint**: `PUT /items/{item_id}`

**Status**: ❌ Not implemented

---

### Delete Item

**Endpoint**: `DELETE /items/{item_id}`

**Status**: ❌ Not implemented

---

## Dashboard API

### Get Dashboard Statistics

**Endpoint**: `GET /dashboard/stats`

**Status**: ❌ Not implemented (planned for Phase 2)

**Response**: `200 OK`
```json
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
    "passed": 190,
    "failed": 10,
    "pass_rate": 0.95
  },
  "inventory": {
    "total_items": 50,
    "low_stock_count": 3
  },
  "employees": {
    "total": 15,
    "certifications_expiring_soon": 2
  }
}
```

---

### Get Work Order Analytics

**Endpoint**: `GET /dashboard/workorders`

**Status**: ❌ Not implemented

**Response**: `200 OK`
```json
{
  "by_status": {
    "Pending": 45,
    "In Progress": 30,
    "Completed": 75
  },
  "by_month": [
    {"month": "2024-01", "count": 10},
    {"month": "2024-02", "count": 15}
  ]
}
```

---

### Get Inventory Alerts

**Endpoint**: `GET /dashboard/inventory/alerts`

**Status**: ❌ Not implemented

**Response**: `200 OK`
```json
[
  {
    "item_id": "ITM-001",
    "item_name": "Steel Rods",
    "quantity": 15,
    "reorder_level": 20,
    "status": "low_stock"
  }
]
```

---

## File Upload API

### Upload Excel File

**Endpoint**: `POST /upload/{template_id}`

**Status**: ✅ Implemented (needs improvements)

**Path Parameters**:
- `template_id` (integer, required) - Template ID to use for import

**Request**: `multipart/form-data`
- `file` (file, required) - Excel file (.xlsx, .xls)

**File Constraints** (to be added):
- Max file size: 10MB
- Allowed types: .xlsx, .xls

**Response**: `200 OK`
```json
{
  "imported": 25,
  "template_id": 1,
  "file_name": "data.xlsx"
}
```

**Error Responses**:
- `400 Bad Request` - Invalid file type or size
- `404 Not Found` - Template not found
- `422 Unprocessable Entity` - File format error

---

## Scheduling API

### Schedule Daily Import

**Endpoint**: `POST /schedule/import/{template_id}`

**Status**: ✅ Implemented (needs improvements)

**Path Parameters**:
- `template_id` (integer, required)

**Query Parameters**:
- `hour` (integer, required, 0-23) - Hour of day
- `minute` (integer, required, 0-59) - Minute of hour
- `path` (string, required) - Path to Excel file

**Response**: `200 OK`
```json
{
  "scheduled": "import_1_2_0",
  "template_id": 1,
  "schedule": {
    "hour": 2,
    "minute": 0,
    "next_run": "2024-12-02T02:00:00Z"
  }
}
```

**Error Responses**:
- `400 Bad Request` - Invalid schedule parameters or file path

---

## Health Check API

### Health Check

**Endpoint**: `GET /health`

**Status**: ❌ Not implemented (planned for Phase 1)

**Response**: `200 OK`
```json
{
  "status": "healthy",
  "timestamp": "2024-12-01T12:00:00Z",
  "version": "1.0.0"
}
```

---

### Database Health Check

**Endpoint**: `GET /health/db`

**Status**: ❌ Not implemented

**Response**: `200 OK`
```json
{
  "status": "healthy",
  "database": "connected",
  "response_time_ms": 15
}
```

**Error Response**: `503 Service Unavailable`
```json
{
  "status": "unhealthy",
  "database": "disconnected",
  "error": "Connection timeout"
}
```

---

## Rate Limiting

**Status**: ❌ Not implemented (planned for Phase 3)

**Planned Limits**:
- General endpoints: 100 requests/minute per IP
- Upload endpoints: 10 requests/minute per IP
- Authentication endpoints: 5 requests/minute per IP

**Headers**:
```
X-RateLimit-Limit: 100
X-RateLimit-Remaining: 95
X-RateLimit-Reset: 1638360000
```

---

## API Versioning

**Current Version**: v1

**Future Versions**: Will be implemented as `/v2/...` endpoints

---

## Changelog

### v1.0 (Current)
- ✅ Basic CRUD operations (CREATE, LIST)
- ✅ File upload endpoint
- ✅ Scheduling endpoint
- ❌ Missing: GET by ID, UPDATE, DELETE
- ❌ Missing: Pagination, filtering, sorting
- ❌ Missing: Dashboard endpoints
- ❌ Missing: Authentication

### v1.1 (Planned - Phase 1)
- Complete CRUD operations
- Health check endpoint
- Improved error handling

### v1.2 (Planned - Phase 2)
- Pagination and filtering
- Dashboard endpoints
- AWS S3 integration

### v2.0 (Planned - Phase 3)
- Authentication system
- Rate limiting
- Enhanced security

---

**Document Version**: 1.0  
**Last Updated**: December 2024  
**Interactive Docs**: https://welding-backend-v1-0.onrender.com/docs

