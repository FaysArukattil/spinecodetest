// ignore_for_file: prefer_initializing_formals
import 'package:flutter/foundation.dart';

import '../../../../core/errors/failures.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/usecases/get_session_usecase.dart';
import '../../domain/usecases/login_usecase.dart';
import '../../domain/usecases/logout_usecase.dart';

enum AuthStatus { unknown, authenticated, unauthenticated }

class AuthProvider extends ChangeNotifier {
  final LoginUseCase _login;
  final LogoutUseCase _logout;
  final GetSessionUseCase _getSession;

  AuthProvider({
    required LoginUseCase login,
    required LogoutUseCase logout,
    required GetSessionUseCase getSession,
  }) : _login = login,
       _logout = logout,
       _getSession = getSession;

  AuthStatus _status = AuthStatus.unknown;
  UserEntity? _user;
  bool _isLoading = false;
  String? _error;

  AuthStatus get status => _status;
  UserEntity? get user => _user;
  bool get isLoading => _isLoading;
  String? get error => _error;

  /// Called once at app start (splash) for auto-login.
  Future<void> checkSession() async {
    try {
      _user = await _getSession();
    } catch (_) {
      _user = null;
    }
    _status = _user != null
        ? AuthStatus.authenticated
        : AuthStatus.unauthenticated;
    notifyListeners();
  }

  Future<bool> login(String email, String password) async {
    if (_isLoading) return false; // prevent duplicate submission
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      _user = await _login(email, password);
      _status = AuthStatus.authenticated;
      return true;
    } catch (e) {
      _error = Failure.from(e).message;
      _status = AuthStatus.unauthenticated;
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    await _logout();
    _user = null;
    _status = AuthStatus.unauthenticated;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
