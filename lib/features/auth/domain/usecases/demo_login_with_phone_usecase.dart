import '../entities/user_entity.dart';
import '../repositories/auth_repository.dart';

class DemoLoginWithPhoneUseCase {
  final AuthRepository repo;
  const DemoLoginWithPhoneUseCase(this.repo);

  Future<UserEntity> call(String phone) => repo.demoLoginWithPhone(phone);
}
