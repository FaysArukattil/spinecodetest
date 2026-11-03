// ignore_for_file: prefer_initializing_formals
import 'dart:async';
import 'package:flutter/foundation.dart';

import '../../../../core/errors/failures.dart';
import '../../domain/entities/staff_entity.dart';
import '../../domain/usecases/add_staff_usecase.dart';
import '../../domain/usecases/delete_staff_usecase.dart';
import '../../domain/usecases/get_staff_usecase.dart';
import '../../domain/usecases/update_staff_usecase.dart';

class StaffProvider extends ChangeNotifier {
  final GetStaffUseCase _getStaff;
  final AddStaffUseCase _addStaff;
  final UpdateStaffUseCase _updateStaff;
  final DeleteStaffUseCase _deleteStaff;

  StaffProvider({
    required GetStaffUseCase getStaff,
    required AddStaffUseCase addStaff,
    required UpdateStaffUseCase updateStaff,
    required DeleteStaffUseCase deleteStaff,
  })  : _getStaff = getStaff,
        _addStaff = addStaff,
        _updateStaff = updateStaff,
        _deleteStaff = deleteStaff;

  StreamSubscription<List<StaffEntity>>? _sub;
  List<StaffEntity> _staffList = [];
  bool _loading = true;
  bool _saving = false;
  String? _error;

  List<StaffEntity> get staffList => _staffList;
  bool get isLoading => _loading;
  bool get isSaving => _saving;
  String? get error => _error;

  void start({bool force = false}) {
    if (_sub != null && !force) return;
    _sub?.cancel();
    _loading = true;
    _error = null;
    notifyListeners();
    _sub = _getStaff().listen(
      (list) {
        _staffList = list;
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
    _staffList = [];
    _loading = true;
    _error = null;
  }

  Future<String?> save(StaffEntity s) =>
      _run(() => s.id.isEmpty ? _addStaff(s) : _updateStaff(s));

  Future<String?> delete(String id) => _run(() => _deleteStaff(id));

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
