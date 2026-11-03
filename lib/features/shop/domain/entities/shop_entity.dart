import '../../../../core/constants/app_constants.dart';

class ShopEntity {
  final String id; // same as the Firebase Auth uid of the shop
  final String shopName;
  final String ownerName;
  final String email;
  final String phone;
  final String address;
  final String status; // Active | Blocked
  final DateTime createdAt;

  const ShopEntity({
    required this.id,
    required this.shopName,
    required this.ownerName,
    required this.email,
    required this.phone,
    required this.address,
    required this.status,
    required this.createdAt,
  });

  bool get isActive => status == AppConstants.shopActive;

  ShopEntity copyWith({String? status}) => ShopEntity(
        id: id,
        shopName: shopName,
        ownerName: ownerName,
        email: email,
        phone: phone,
        address: address,
        status: status ?? this.status,
        createdAt: createdAt,
      );
}
