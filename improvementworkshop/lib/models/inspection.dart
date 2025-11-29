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