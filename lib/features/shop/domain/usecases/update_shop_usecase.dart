import '../entities/shop_entity.dart';
import '../repositories/shop_repository.dart';

class UpdateShopUseCase {
  final ShopRepository repository;
  const UpdateShopUseCase(this.repository);
  Future<void> call(ShopEntity shop) => repository.updateShop(shop);
}
