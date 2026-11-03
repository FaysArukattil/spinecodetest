// ignore_for_file: prefer_initializing_formals
import 'package:flutter/foundation.dart';

import '../../../../core/errors/failures.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/usecases/demo_login_with_phone_usecase.dart';
import '../../domain/usecases/get_session_usecase.dart';
import '../../domain/usecases/login_usecase.dart';
import '../../domain/usecases/login_with_phone_usecase.dart';
import '../../domain/usecases/logout_usecase.dart';
import '../../domain/usecases/verify_phone_usecase.dart';

enum AuthStatus { unknown, authenticated, unauthenticated }

class AuthProvider extends ChangeNotifier {
  final LoginUseCase _login;
  final LogoutUseCase _logout;
  final GetSessionUseCase _getSession;
  final VerifyPhoneUseCase _verifyPhone;
  final LoginWithPhoneUseCase _loginWithPhone;
  final DemoLoginWithPhoneUseCase _demoLoginWithPhone;

  AuthProvider({
    required LoginUseCase login,
    required LogoutUseCase logout,
    required GetSessionUseCase getSession,
    required VerifyPhoneUseCase verifyPhone,
    required LoginWithPhoneUseCase loginWithPhone,
    required DemoLoginWithPhoneUseCase demoLoginWithPhone,
  }) : _login = login,
       _logout = logout,
       _getSession = getSession,
       _verifyPhone = verifyPhone,
       _loginWithPhone = loginWithPhone,
       _demoLoginWithPhone = demoLoginWithPhone;

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

  Future<void> sendPhoneOtp({
    required String phone,
    required void Function(String verificationId, int? resendToken) onCodeSent,
    required void Function(String error) onError,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      await _verifyPhone(
        phone: phone,
        onCodeSent: (id, token) {
          _isLoading = false;
          notifyListeners();
          onCodeSent(id, token);
        },
        onError: (err) {
          _isLoading = false;
          _error = err;
          notifyListeners();
          onError(err);
        },
        onAutoVerified: (credential) async {
          _isLoading = false;
          notifyListeners();
        },
      );
    } catch (e) {
      _isLoading = false;
      _error = Failure.from(e).message;
      notifyListeners();
      onError(_error!);
    }
  }

  Future<bool> verifyOtpAndLogin({
    required String verificationId,
    required String smsCode,
  }) async {
    if (_isLoading) return false;
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      _user = await _loginWithPhone(verificationId, smsCode);
      _status = AuthStatus.authenticated;
      return true;
    } catch (e) {
      _error = Failure.from(e).message;
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> loginWithDemoPhone(String phone) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      _user = await _demoLoginWithPhone(phone);
      _status = AuthStatus.authenticated;
      return true;
    } catch (e) {
      _error = Failure.from(e).message;
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
