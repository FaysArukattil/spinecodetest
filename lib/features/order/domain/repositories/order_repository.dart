import '../entities/order_entity.dart';

abstract class OrderRepository {
  Stream<List<OrderEntity>> watchAllOrders();
  Stream<List<OrderEntity>> watchShopOrders(String shopId);

  /// Atomically validates stock, deducts it and creates the order.
  /// Calling it twice with the same order id has no effect (duplicate guard).
  Future<void> placeOrder(OrderEntity order);

  Future<void> updateStatus(String orderId, String newStatus);
}
