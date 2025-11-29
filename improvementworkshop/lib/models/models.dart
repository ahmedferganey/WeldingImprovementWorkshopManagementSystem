// Work Order Model
class WorkOrder {
  final int? id;
  final String orderId;
  final String client;
  final String? description;
  final String? status;
  final DateTime? dueDate;
  final String? assignedWelder;

  WorkOrder({
    this.id,
    required this.orderId,
    required this.client,
    this.description,
    this.status,
    this.dueDate,
    this.assignedWelder,
  });

  factory WorkOrder.fromJson(Map<String, dynamic> json) {
    return WorkOrder(
      id: json['id'],
      orderId: json['order_id'],
      client: json['client'],
      description: json['description'],
      status: json['status'],
      dueDate: json['due_date'] != null ? DateTime.parse(json['due_date']) : null,
      assignedWelder: json['assigned_welder'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'order_id': orderId,
      'client': client,
      'description': description,
      'status': status,
      'due_date': dueDate?.toIso8601String(),
      'assigned_welder': assignedWelder,
    };
  }
}

// Equipment Model
class Equipment {
  final int? id;
  final String equipmentId;
  final String name;
  final String? status;
  final DateTime? lastServiceDate;

  Equipment({
    this.id,
    required this.equipmentId,
    required this.name,
    this.status,
    this.lastServiceDate,
  });

  factory Equipment.fromJson(Map<String, dynamic> json) {
    return Equipment(
      id: json['id'],
      equipmentId: json['equipment_id'],
      name: json['name'],
      status: json['status'],
      lastServiceDate: json['last_service_date'] != null
          ? DateTime.parse(json['last_service_date'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'equipment_id': equipmentId,
      'name': name,
      'status': status,
      'last_service_date': lastServiceDate?.toIso8601String(),
    };
  }
}

// Inspection Model
class Inspection {
  final int? id;
  final String inspectionId;
  final String orderId;
  final String inspector;
  final String result;
  final String? defectType;

  Inspection({
    this.id,
    required this.inspectionId,
    required this.orderId,
    required this.inspector,
    required this.result,
    this.defectType,
  });

  factory Inspection.fromJson(Map<String, dynamic> json) {
    return Inspection(
      id: json['id'],
      inspectionId: json['inspection_id'],
      orderId: json['order_id'],
      inspector: json['inspector'],
      result: json['result'],
      defectType: json['defect_type'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'inspection_id': inspectionId,
      'order_id': orderId,
      'inspector': inspector,
      'result': result,
      'defect_type': defectType,
    };
  }
}

// Employee Model
class Employee {
  final int? id;
  final String employeeId;
  final String name;
  final String? role;
  final DateTime? certificationExpiry;

  Employee({
    this.id,
    required this.employeeId,
    required this.name,
    this.role,
    this.certificationExpiry,
  });

  factory Employee.fromJson(Map<String, dynamic> json) {
    return Employee(
      id: json['id'],
      employeeId: json['employee_id'],
      name: json['name'],
      role: json['role'],
      certificationExpiry: json['certification_expiry'] != null
          ? DateTime.parse(json['certification_expiry'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'employee_id': employeeId,
      'name': name,
      'role': role,
      'certification_expiry': certificationExpiry?.toIso8601String(),
    };
  }
}

// Item Model (Inventory)
class Item {
  final int? id;
  final String itemId;
  final String itemName;
  final int? quantity;
  final String? unit;
  final int? reorderLevel;

  Item({
    this.id,
    required this.itemId,
    required this.itemName,
    this.quantity,
    this.unit,
    this.reorderLevel,
  });

  factory Item.fromJson(Map<String, dynamic> json) {
    return Item(
      id: json['id'],
      itemId: json['item_id'],
      itemName: json['item_name'],
      quantity: json['quantity'],
      unit: json['unit'],
      reorderLevel: json['reorder_level'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'item_id': itemId,
      'item_name': itemName,
      'quantity': quantity,
      'unit': unit,
      'reorder_level': reorderLevel,
    };
  }
}

// Machine Model
class Machine {
  final int? id;
  final String name;
  final String code;
  final String? type;
  final Map<String, dynamic>? metadata;

  Machine({
    this.id,
    required this.name,
    required this.code,
    this.type,
    this.metadata,
  });

  factory Machine.fromJson(Map<String, dynamic> json) {
    return Machine(
      id: json['id'],
      name: json['name'],
      code: json['code'],
      type: json['type'],
      metadata: json['metadata'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'code': code,
      'type': type,
      'metadata': metadata ?? {},
    };
  }
}

// Template Model
class Template {
  final int? id;
  final String name;
  final String? description;
  final int machineId;
  final Map<String, String> mapping;

  Template({
    this.id,
    required this.name,
    this.description,
    required this.machineId,
    required this.mapping,
  });

  factory Template.fromJson(Map<String, dynamic> json) {
    return Template(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      machineId: json['machine_id'],
      mapping: Map<String, String>.from(json['mapping']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'description': description,
      'machine_id': machineId,
      'mapping': mapping,
    };
  }
}