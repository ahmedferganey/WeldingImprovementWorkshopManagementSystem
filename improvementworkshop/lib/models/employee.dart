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