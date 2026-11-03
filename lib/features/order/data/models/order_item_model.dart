import '../../../../core/constants/firestore_keys.dart';
import '../../domain/entities/order_item_entity.dart';

class OrderItemModel extends OrderItemEntity {
  const OrderItemModel({
    required super.vegetableId,
    required super.name,
    required super.unit,
    required super.price,
    required super.quantity,
  });

  factory OrderItemModel.fromEntity(OrderItemEntity e) => OrderItemModel(
        vegetableId: e.vegetableId,
        name: e.name,
        unit: e.unit,
        price: e.price,
        quantity: e.quantity,
      );

  factory OrderItemModel.fromMap(Map<String, dynamic> m) => OrderItemModel(
        vegetableId: (m[FirestoreKeys.vegetableId] ?? '') as String,
        name: (m[FirestoreKeys.name] ?? '') as String,
        unit: (m[FirestoreKeys.unit] ?? '') as String,
        price: ((m[FirestoreKeys.price] ?? 0) as num).toDouble(),
        quantity: ((m[FirestoreKeys.quantity] ?? 0) as num).toDouble(),
      );

  Map<String, dynamic> toMap() => {
        FirestoreKeys.vegetableId: vegetableId,
        FirestoreKeys.name: name,
        FirestoreKeys.unit: unit,
        FirestoreKeys.price: price,
        FirestoreKeys.quantity: quantity,
      };
}
