import '../repositories/order_repository.dart';

class UpdateOrderStatusUseCase {
  final OrderRepository repository;
  const UpdateOrderStatusUseCase(this.repository);
  Future<void> call(String orderId, String status) =>
      repository.updateStatus(orderId, status);
}
