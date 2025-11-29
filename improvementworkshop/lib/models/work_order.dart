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