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