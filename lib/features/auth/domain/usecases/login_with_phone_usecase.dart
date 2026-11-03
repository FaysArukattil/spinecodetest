import '../entities/user_entity.dart';
import '../repositories/auth_repository.dart';

class LoginWithPhoneUseCase {
  final AuthRepository repo;
  const LoginWithPhoneUseCase(this.repo);

  Future<UserEntity> call(String verificationId, String smsCode) =>
      repo.loginWithPhone(verificationId, smsCode);
}
