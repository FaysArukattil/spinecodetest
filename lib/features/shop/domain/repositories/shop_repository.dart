import '../entities/shop_entity.dart';

abstract class ShopRepository {
  Stream<List<ShopEntity>> watchShops();

  /// Creates the shop's login (Firebase Auth) and its Firestore documents.
  Future<void> addShop(ShopEntity shop, String password);
  Future<void> updateShop(ShopEntity shop);
  Future<void> deleteShop(String id);
  Future<void> setStatus(String id, String status);
}
