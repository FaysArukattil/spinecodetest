import '../entities/order_entity.dart';
import '../repositories/order_repository.dart';

class GetOrdersUseCase {
  final OrderRepository repository;
  const GetOrdersUseCase(this.repository);
  Stream<List<OrderEntity>> call() => repository.watchAllOrders();
}
