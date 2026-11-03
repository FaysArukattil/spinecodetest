import '../../../../core/constants/app_constants.dart';
import '../entities/shop_entity.dart';
import '../repositories/shop_repository.dart';

/// Block / Activate a shop. Blocked shops cannot log in.
class ToggleShopStatusUseCase {
  final ShopRepository repository;
  const ToggleShopStatusUseCase(this.repository);

  Future<void> call(ShopEntity shop, bool activate) => repository.setStatus(
        shop.id,
        activate ? AppConstants.shopActive : AppConstants.shopBlocked,
      );
}
