import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/constants/firestore_keys.dart';
import '../../domain/entities/vegetable_entity.dart';

class VegetableModel extends VegetableEntity {
  const VegetableModel({
    required super.id,
    required super.name,
    required super.sortNumber,
    required super.unit,
    required super.price,
    required super.stockQuantity,
    required super.status,
    required super.createdAt,
  });

  factory VegetableModel.fromEntity(VegetableEntity e) => VegetableModel(
        id: e.id,
        name: e.name,
        sortNumber: e.sortNumber,
        unit: e.unit,
        price: e.price,
        stockQuantity: e.stockQuantity,
        status: e.status,
        createdAt: e.createdAt,
      );

  factory VegetableModel.fromDoc(DocumentSnapshot<Map<String, dynamic>> d) {
    final m = d.data() ?? {};
    return VegetableModel(
      id: d.id,
      name: (m[FirestoreKeys.name] ?? '') as String,
      sortNumber: ((m[FirestoreKeys.sortNumber] ?? 0) as num).toInt(),
      unit: (m[FirestoreKeys.unit] ?? AppConstants.units.first) as String,
      price: ((m[FirestoreKeys.price] ?? 0) as num).toDouble(),
      stockQuantity: ((m[FirestoreKeys.stockQuantity] ?? 0) as num).toDouble(),
      status: (m[FirestoreKeys.status] ?? AppConstants.vegOutOfStock) as String,
      createdAt:
          (m[FirestoreKeys.createdAt] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() => {
        FirestoreKeys.name: name,
        FirestoreKeys.sortNumber: sortNumber,
        FirestoreKeys.unit: unit,
        FirestoreKeys.price: price,
        FirestoreKeys.stockQuantity: stockQuantity,
        FirestoreKeys.status: status,
        FirestoreKeys.createdAt: Timestamp.fromDate(createdAt),
      };
}
