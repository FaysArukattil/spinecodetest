import '../../../order/domain/entities/order_item_entity.dart';

class CartItemEntity {
  final String vegetableId;
  final String name;
  final String unit;
  final double price;
  final double quantity;

  const CartItemEntity({
    required this.vegetableId,
    required this.name,
    required this.unit,
    required this.price,
    required this.quantity,
  });

  double get lineTotal => price * quantity;

  CartItemEntity copyWith({double? price, double? quantity}) => CartItemEntity(
        vegetableId: vegetableId,
        name: name,
        unit: unit,
        price: price ?? this.price,
        quantity: quantity ?? this.quantity,
      );

  OrderItemEntity toOrderItem() => OrderItemEntity(
        vegetableId: vegetableId,
        name: name,
        unit: unit,
        price: price,
        quantity: quantity,
      );
}
