import '../entities/shop_entity.dart';
import '../repositories/shop_repository.dart';

class GetShopsUseCase {
  final ShopRepository repository;
  const GetShopsUseCase(this.repository);
  Stream<List<ShopEntity>> call() => repository.watchShops();
}
