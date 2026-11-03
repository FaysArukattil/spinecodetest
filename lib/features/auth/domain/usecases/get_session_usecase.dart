import '../entities/user_entity.dart';
import '../repositories/auth_repository.dart';

class GetSessionUseCase {
  final AuthRepository repository;
  const GetSessionUseCase(this.repository);
  Future<UserEntity?> call() => repository.getSession();
}
