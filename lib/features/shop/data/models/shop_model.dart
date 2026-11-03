import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/constants/firestore_keys.dart';
import '../../domain/entities/shop_entity.dart';

class ShopModel extends ShopEntity {
  const ShopModel({
    required super.id,
    required super.shopName,
    required super.ownerName,
    required super.email,
    required super.phone,
    required super.address,
    required super.status,
    required super.createdAt,
  });

  factory ShopModel.fromEntity(ShopEntity e) => ShopModel(
        id: e.id,
        shopName: e.shopName,
        ownerName: e.ownerName,
        email: e.email,
        phone: e.phone,
        address: e.address,
        status: e.status,
        createdAt: e.createdAt,
      );

  factory ShopModel.fromDoc(DocumentSnapshot<Map<String, dynamic>> d) {
    final m = d.data() ?? {};
    return ShopModel(
      id: d.id,
      shopName: (m[FirestoreKeys.shopName] ?? '') as String,
      ownerName: (m[FirestoreKeys.ownerName] ?? '') as String,
      email: (m[FirestoreKeys.email] ?? '') as String,
      phone: (m[FirestoreKeys.phone] ?? '') as String,
      address: (m[FirestoreKeys.address] ?? '') as String,
      status: (m[FirestoreKeys.status] ?? AppConstants.shopBlocked) as String,
      createdAt:
          (m[FirestoreKeys.createdAt] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() => {
        FirestoreKeys.shopName: shopName,
        FirestoreKeys.ownerName: ownerName,
        FirestoreKeys.email: email,
        FirestoreKeys.phone: phone,
        FirestoreKeys.address: address,
        FirestoreKeys.status: status,
        FirestoreKeys.createdAt: Timestamp.fromDate(createdAt),
      };
}
