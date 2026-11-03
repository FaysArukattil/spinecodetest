import 'dart:async';
import 'package:flutter/foundation.dart';

import '../../../../core/errors/failures.dart';
import '../../domain/entities/shop_entity.dart';
import '../../domain/usecases/add_shop_usecase.dart';
import '../../domain/usecases/delete_shop_usecase.dart';
import '../../domain/usecases/get_shops_usecase.dart';
import '../../domain/usecases/toggle_shop_status_usecase.dart';
import '../../domain/usecases/update_shop_usecase.dart';

class ShopProvider extends ChangeNotifier {
  final GetShopsUseCase _get;
  final AddShopUseCase _add;
  final UpdateShopUseCase _update;
  final DeleteShopUseCase _delete;
  final ToggleShopStatusUseCase _toggle;

  ShopProvider({
    required GetShopsUseCase getShops,
    required AddShopUseCase addShop,
    required UpdateShopUseCase updateShop,
    required DeleteShopUseCase deleteShop,
    required ToggleShopStatusUseCase toggleStatus,
  })  : _get = getShops,
        _add = addShop,
        _update = updateShop,
        _delete = deleteShop,
        _toggle = toggleStatus;

  StreamSubscription<List<ShopEntity>>? _sub;
  List<ShopEntity> _shops = [];
  bool _loading = true;
  bool _saving = false;
  String? _error;

  List<ShopEntity> get shops => _shops;
  bool get isLoading => _loading;
  bool get isSaving => _saving;
  String? get error => _error;

  void start({bool force = false}) {
    if (_sub != null && !force) return;
    _sub?.cancel();
    _loading = true;
    _error = null;
    notifyListeners();
    _sub = _get().listen(
      (list) {
        _shops = list;
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

  void stop() {
    _sub?.cancel();
    _sub = null;
    _shops = [];
    _loading = true;
    _error = null;
  }

  /// [password] is required only when adding a new shop (id is empty).
  Future<String?> save(ShopEntity shop, {String? password}) => _run(
        () => shop.id.isEmpty ? _add(shop, password ?? '') : _update(shop),
      );

  Future<String?> setActive(ShopEntity shop, bool active) =>
      _run(() => _toggle(shop, active));

  Future<String?> delete(String id) => _run(() => _delete(id));

  Future<String?> _run(Future<void> Function() action) async {
    if (_saving) return 'Please wait...';
    _saving = true;
    notifyListeners();
    try {
      await action();
      return null;
    } catch (e) {
      return Failure.from(e).message;
    } finally {
      _saving = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }
}
