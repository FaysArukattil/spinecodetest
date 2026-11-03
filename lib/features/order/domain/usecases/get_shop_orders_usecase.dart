import '../entities/order_entity.dart';
import '../repositories/order_repository.dart';

class GetShopOrdersUseCase {
  final OrderRepository repository;
  const GetShopOrdersUseCase(this.repository);
  Stream<List<OrderEntity>> call(String shopId) =>
      repository.watchShopOrders(shopId);
}
