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