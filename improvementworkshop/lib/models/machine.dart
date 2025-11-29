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