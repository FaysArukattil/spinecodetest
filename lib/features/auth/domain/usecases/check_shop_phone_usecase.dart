import '../repositories/auth_repository.dart';

class CheckShopPhoneUseCase {
  final AuthRepository repo;
  const CheckShopPhoneUseCase(this.repo);

  Future<void> call(String phone) => repo.checkShopRegistered(phone);
}
