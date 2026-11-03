import '../../../../core/constants/app_constants.dart';

class VegetableEntity {
  final String id;
  final String name;
  final int sortNumber;
  final String unit;
  final double price;
  final double stockQuantity;
  final String status; // Available | Out of Stock
  final DateTime createdAt;

  const VegetableEntity({
    required this.id,
    required this.name,
    required this.sortNumber,
    required this.unit,
    required this.price,
    required this.stockQuantity,
    required this.status,
    required this.createdAt,
  });

  bool get isAvailable => status == AppConstants.vegAvailable;

  VegetableEntity copyWith({String? status}) => VegetableEntity(
        id: id,
        name: name,
        sortNumber: sortNumber,
        unit: unit,
        price: price,
        stockQuantity: stockQuantity,
        status: status ?? this.status,
        createdAt: createdAt,
      );
}
