import '../../../../core/constants/app_constants.dart';
import '../repositories/order_repository.dart';

/// Shop cancels its own order. Allowed only while the order is Pending
/// (enforced again inside the Firestore transaction).
class CancelOrderUseCase {
  final OrderRepository repository;
  const CancelOrderUseCase(this.repository);
  Future<void> call(String orderId) =>
      repository.updateStatus(orderId, AppConstants.orderCancelled);
}
