import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/constants/firestore_keys.dart';
import '../../domain/entities/order_entity.dart';
import 'order_item_model.dart';

class OrderModel extends OrderEntity {
  const OrderModel({
    required super.id,
    required super.shopId,
    required super.shopName,
    required super.items,
    required super.totalAmount,
    required super.status,
    required super.createdAt,
  });

  factory OrderModel.fromEntity(OrderEntity e) => OrderModel(
        id: e.id,
        shopId: e.shopId,
        shopName: e.shopName,
        items: e.items,
        totalAmount: e.totalAmount,
        status: e.status,
        createdAt: e.createdAt,
      );

  factory OrderModel.fromDoc(DocumentSnapshot<Map<String, dynamic>> d) {
    final m = d.data() ?? {};
    final rawItems = (m[FirestoreKeys.items] as List?) ?? const [];
    return OrderModel(
      id: d.id,
      shopId: (m[FirestoreKeys.shopId] ?? '') as String,
      shopName: (m[FirestoreKeys.shopName] ?? '') as String,
      items: rawItems
          .map((e) => OrderItemModel.fromMap(Map<String, dynamic>.from(e as Map)))
          .toList(),
      totalAmount: ((m[FirestoreKeys.totalAmount] ?? 0) as num).toDouble(),
      status: (m[FirestoreKeys.status] ?? AppConstants.orderPending) as String,
      createdAt:
          (m[FirestoreKeys.createdAt] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() => {
        FirestoreKeys.shopId: shopId,
        FirestoreKeys.shopName: shopName,
        FirestoreKeys.items:
            items.map((i) => OrderItemModel.fromEntity(i).toMap()).toList(),
        FirestoreKeys.totalAmount: totalAmount,
        FirestoreKeys.status: status,
        FirestoreKeys.createdAt: Timestamp.fromDate(createdAt),
      };
}
