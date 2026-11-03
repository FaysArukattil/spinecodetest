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
}
