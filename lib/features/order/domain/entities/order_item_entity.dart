class OrderItemEntity {
  final String vegetableId;
  final String name;
  final String unit;
  final double price;
  final double quantity;

  const OrderItemEntity({
    required this.vegetableId,
    required this.name,
    required this.unit,
    required this.price,
    required this.quantity,
  });

  double get lineTotal => price * quantity;
}
