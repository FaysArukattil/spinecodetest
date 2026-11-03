import '../../domain/entities/shop_entity.dart';
import '../../domain/repositories/shop_repository.dart';
import '../datasources/shop_remote_datasource.dart';
import '../models/shop_model.dart';

class ShopRepositoryImpl implements ShopRepository {
  final ShopRemoteDataSource remote;
  const ShopRepositoryImpl(this.remote);

  @override
  Stream<List<ShopEntity>> watchShops() => remote.watchAll();

  @override
  Future<void> addShop(ShopEntity shop, String password) =>
      remote.add(ShopModel.fromEntity(shop), password);

  @override
  Future<void> updateShop(ShopEntity shop) =>
      remote.update(ShopModel.fromEntity(shop));

  @override
  Future<void> deleteShop(String id) => remote.delete(id);

  @override
  Future<void> setStatus(String id, String status) =>
      remote.setStatus(id, status);
}
