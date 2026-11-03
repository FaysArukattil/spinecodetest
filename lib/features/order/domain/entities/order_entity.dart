import '../../../../core/constants/app_constants.dart';
import 'order_item_entity.dart';

class OrderEntity {
  final String id;
  final String shopId;
  final String shopName;
  final List<OrderItemEntity> items;
  final double totalAmount;
  final String status; // Pending | Approved | Rejected | Completed | Cancelled
  final DateTime createdAt;

  const OrderEntity({
    required this.id,
    required this.shopId,
    required this.shopName,
    required this.items,
    required this.totalAmount,
    required this.status,
    required this.createdAt,
  });

  /// Short, readable id for the UI, e.g. ORD3F9A1C
  String get displayId =>
      'ORD${id.replaceAll('-', '').substring(0, id.length < 6 ? id.length : 6).toUpperCase()}';

  /// Shop may cancel only while the order is still Pending.
  bool get canCancel => status == AppConstants.orderPending;
}
