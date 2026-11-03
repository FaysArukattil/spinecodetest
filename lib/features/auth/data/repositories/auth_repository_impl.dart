import 'package:firebase_auth/firebase_auth.dart';

import '../../../../core/errors/exceptions.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_local_datasource.dart';
import '../datasources/auth_remote_datasource.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remote;
  final AuthLocalDataSource local;
  const AuthRepositoryImpl({required this.remote, required this.local});

  @override
  Future<UserEntity> login(String email, String password) async {
    final user = await remote.login(email, password);
    await local.saveSession(user);
    return user;
  }

  /// Auto-login: trust saved session, but re-verify role/blocked status online.
  /// If offline, fall back to the saved session.
  @override
  Future<UserEntity?> getSession() async {
    final saved = local.getSession();
    if (saved == null || !remote.hasUser) {
      await local.clear();
      return null;
    }
    try {
      final fresh = await remote.restore();
      if (fresh == null) {
        await local.clear();
        return null;
      }
      await local.saveSession(fresh);
      return fresh;
    } on AppException {
      // e.g. shop was blocked since last login
      await logout();
      return null;
    } catch (_) {
      return saved; // network problem: keep user signed in
    }
  }

  @override
  Future<void> logout() async {
    await remote.logout();
    await local.clear(); // clears all saved session data
  }

  @override
  Future<void> verifyPhoneNumber({
    required String phone,
    required void Function(String verificationId, int? resendToken) onCodeSent,
    required void Function(String error) onError,
    required void Function(PhoneAuthCredential credential) onAutoVerified,
  }) =>
      remote.verifyPhoneNumber(
        phone: phone,
        onCodeSent: onCodeSent,
        onError: onError,
        onAutoVerified: onAutoVerified,
      );

  @override
  Future<UserEntity> loginWithPhone(String verificationId, String smsCode) async {
    final user = await remote.signInWithPhoneCode(
      verificationId: verificationId,
      smsCode: smsCode,
    );
    await local.saveSession(user);
    return user;
  }

  @override
  Future<UserEntity> demoLoginWithPhone(String phone) async {
    final user = await remote.demoLoginWithPhone(phone);
    await local.saveSession(user);
    return user;
  }
}
