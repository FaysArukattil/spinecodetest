import '../entities/shop_entity.dart';
import '../repositories/shop_repository.dart';

class AddShopUseCase {
  final ShopRepository repository;
  const AddShopUseCase(this.repository);
  Future<void> call(ShopEntity shop, String password) =>
      repository.addShop(shop, password);
}
