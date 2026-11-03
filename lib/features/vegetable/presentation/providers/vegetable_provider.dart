import 'dart:async';
import 'package:flutter/foundation.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/vegetable_entity.dart';
import '../../domain/usecases/add_vegetable_usecase.dart';
import '../../domain/usecases/delete_vegetable_usecase.dart';
import '../../domain/usecases/get_vegetables_usecase.dart';
import '../../domain/usecases/update_vegetable_usecase.dart';

class VegetableProvider extends ChangeNotifier {
  final GetVegetablesUseCase _get;
  final AddVegetableUseCase _add;
  final UpdateVegetableUseCase _update;
  final DeleteVegetableUseCase _delete;

  VegetableProvider({
    required GetVegetablesUseCase getVegetables,
    required AddVegetableUseCase addVegetable,
    required UpdateVegetableUseCase updateVegetable,
    required DeleteVegetableUseCase deleteVegetable,
  })  : _get = getVegetables,
        _add = addVegetable,
        _update = updateVegetable,
        _delete = deleteVegetable;

  StreamSubscription<List<VegetableEntity>>? _sub;
  List<VegetableEntity> _items = [];
  bool _loading = true;
  bool _saving = false;
  String? _error;

  List<VegetableEntity> get items => _items;
  List<VegetableEntity> get available =>
      _items.where((e) => e.isAvailable).toList();
  List<VegetableEntity> get unavailable =>
      _items.where((e) => !e.isAvailable).toList();
  bool get isLoading => _loading;
  bool get isSaving => _saving;
  String? get error => _error;

  /// Starts the realtime listener (safe to call many times).
  void start({bool force = false}) {
    if (_sub != null && !force) return;
    _sub?.cancel();
    _loading = true;
    _error = null;
    notifyListeners();
    _sub = _get().listen(
      (list) {
        _items = list;
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

  /// Called on logout (no notify: it runs while the widget tree builds).
  void stop() {
    _sub?.cancel();
    _sub = null;
    _items = [];
    _loading = true;
    _error = null;
  }

  Future<String?> save(VegetableEntity v) =>
      _run(() => v.id.isEmpty ? _add(v) : _update(v));

  Future<String?> setAvailability(VegetableEntity v, bool available) => _run(
        () => _update(v.copyWith(
          status: available
              ? AppConstants.vegAvailable
              : AppConstants.vegOutOfStock,
        )),
      );

  Future<String?> delete(String id) => _run(() => _delete(id));

  /// Returns null on success, or an error message.
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
