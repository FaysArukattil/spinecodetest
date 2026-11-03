import '../entities/order_entity.dart';
import '../repositories/order_repository.dart';

class PlaceOrderUseCase {
  final OrderRepository repository;
  const PlaceOrderUseCase(this.repository);
  Future<void> call(OrderEntity order) => repository.placeOrder(order);
}
