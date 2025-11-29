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