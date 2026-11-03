import '../repositories/shop_repository.dart';

class DeleteShopUseCase {
  final ShopRepository repository;
  const DeleteShopUseCase(this.repository);
  Future<void> call(String id) => repository.deleteShop(id);
}
