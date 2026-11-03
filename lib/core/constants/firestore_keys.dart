class FirestoreKeys {
  FirestoreKeys._();
  // collections
  static const users = 'users';
  static const vegetables = 'vegetables';
  static const shops = 'shops';
  static const orders = 'orders';
  static const staff = 'staff';

  // common
  static const createdAt = 'createdAt';
  static const status = 'status';

  // vegetable
  static const name = 'name';
  static const sortNumber = 'sortNumber';
  static const price = 'price';
  static const unit = 'unit';
  static const stockQuantity = 'stockQuantity';

  // shop
  static const shopName = 'shopName';
  static const ownerName = 'ownerName';
  static const email = 'email';
  static const phone = 'phone';
  static const address = 'address';

  // order
  static const shopId = 'shopId';
  static const items = 'items';
  static const totalAmount = 'totalAmount';
  static const vegetableId = 'vegetableId';
  static const quantity = 'quantity';

  // users
  static const role = 'role';
}
