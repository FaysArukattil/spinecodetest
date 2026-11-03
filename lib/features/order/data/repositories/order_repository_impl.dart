import '../../domain/entities/order_entity.dart';
import '../../domain/repositories/order_repository.dart';
import '../datasources/order_remote_datasource.dart';
import '../models/order_model.dart';

class OrderRepositoryImpl implements OrderRepository {
  final OrderRemoteDataSource remote;
  const OrderRepositoryImpl(this.remote);

  @override
  Stream<List<OrderEntity>> watchAllOrders() => remote.watchAll();

  @override
  Stream<List<OrderEntity>> watchShopOrders(String shopId) =>
      remote.watchByShop(shopId);

  @override
  Future<void> placeOrder(OrderEntity order) =>
      remote.placeOrder(OrderModel.fromEntity(order));

  @override
  Future<void> updateStatus(String orderId, String newStatus) =>
      remote.updateStatus(orderId, newStatus);
}
