import 'dart:async';
import 'package:flutter/foundation.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/order_entity.dart';
import '../../domain/usecases/cancel_order_usecase.dart';
import '../../domain/usecases/get_orders_usecase.dart';
import '../../domain/usecases/get_shop_orders_usecase.dart';
import '../../domain/usecases/place_order_usecase.dart';
import '../../domain/usecases/update_order_status_usecase.dart';

class OrderProvider extends ChangeNotifier {
  final GetOrdersUseCase _getOrders;
  final GetShopOrdersUseCase _getShopOrders;
  final PlaceOrderUseCase _place;
  final UpdateOrderStatusUseCase _updateStatus;
  final CancelOrderUseCase _cancel;

  OrderProvider({
    required GetOrdersUseCase getOrders,
    required GetShopOrdersUseCase getShopOrders,
    required PlaceOrderUseCase placeOrder,
    required UpdateOrderStatusUseCase updateStatus,
    required CancelOrderUseCase cancelOrder,
  })  : _getOrders = getOrders,
        _getShopOrders = getShopOrders,
        _place = placeOrder,
        _updateStatus = updateStatus,
        _cancel = cancelOrder;

  StreamSubscription<List<OrderEntity>>? _sub;
  String? _scope; // 'all' (store) or a shopId
  List<OrderEntity> _orders = [];
  bool _loading = true;
  bool _busy = false;
  String? _error;

  List<OrderEntity> get orders => _orders;
  bool get isLoading => _loading;
  bool get isBusy => _busy;
  String? get error => _error;

  List<OrderEntity> byStatus(String status) =>
      _orders.where((o) => o.status == status).toList();
  int countOf(String status) => byStatus(status).length;
  OrderEntity? findById(String id) {
    for (final o in _orders) {
      if (o.id == id) return o;
    }
    return null;
  }

  /// Store: listen to every order.
  void startAll({bool force = false}) => _start('all', _getOrders, force);

  /// Shop: listen only to this shop's orders.
  void startForShop(String shopId, {bool force = false}) =>
      _start(shopId, () => _getShopOrders(shopId), force);

  void _start(String scope, Stream<List<OrderEntity>> Function() stream, bool force) {
    if (_sub != null && _scope == scope && !force) return;
    _sub?.cancel();
    _scope = scope;
    _loading = true;
    _error = null;
    notifyListeners();
    _sub = stream().listen(
      (list) {
        _orders = list;
        _loading = false;
        _error = null;
        notifyListeners();
      },
      onError: (Object e) {
        _error = Failure.from(e).message;
        _loading = false;
        notifyListeners();
      },
    );
  }

  /// Retry the current listener.
  void retry(String shopIdOrAll) => shopIdOrAll == 'all'
      ? startAll(force: true)
      : startForShop(shopIdOrAll, force: true);

  void stop() {
    _sub?.cancel();
    _sub = null;
    _scope = null;
    _orders = [];
    _loading = true;
    _error = null;
  }

  /// Returns null on success or an error message.
  Future<String?> placeOrder(OrderEntity order) => _run(() => _place(order));

  Future<String?> updateStatus(String orderId, String status) =>
      _run(() => _updateStatus(orderId, status));

  Future<String?> cancelOrder(String orderId) => _run(() => _cancel(orderId));

  Future<String?> _run(Future<void> Function() action) async {
    if (_busy) return 'Please wait...'; // blocks double taps / duplicate submits
    _busy = true;
    notifyListeners();
    try {
      await action();
      return null;
    } catch (e) {
      return Failure.from(e).message;
    } finally {
      _busy = false;
      notifyListeners();
    }
  }

  // convenience for the store dashboard
  int get pendingCount => countOf(AppConstants.orderPending);
  int get completedCount => countOf(AppConstants.orderCompleted);

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }
}
