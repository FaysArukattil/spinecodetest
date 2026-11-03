import '../entities/order_item_entity.dart';
import '../repositories/order_repository.dart';

class UpdateOrderItemsUseCase {
  final OrderRepository repo;
  const UpdateOrderItemsUseCase(this.repo);

  Future<void> call(String orderId, List<OrderItemEntity> items) =>
      repo.updateOrderItems(orderId, items);
}
