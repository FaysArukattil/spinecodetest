import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/utils/formatters.dart';
import '../../../order/domain/entities/order_entity.dart';
import '../../../vegetable/domain/entities/vegetable_entity.dart';
import '../../domain/entities/cart_item_entity.dart';

/// Holds the shop's cart. Every method that can fail returns an error message
/// (or null on success) so the UI never has to know the rules.
class CartProvider extends ChangeNotifier {
  final Map<String, CartItemEntity> _items = {};

  // Duplicate-submission guard: the same id is reused if the user retries an
  // unchanged cart, so the data layer can recognise and ignore a second write.
  // Any change to the cart creates a new id.
  String? _checkoutId;

  List<CartItemEntity> get items => _items.values.toList();
  bool get isEmpty => _items.isEmpty;
  int get itemCount => _items.length;
  double get totalAmount =>
      _items.values.fold(0.0, (sum, i) => sum + i.lineTotal);

  bool contains(String id) => _items.containsKey(id);
  double quantityOf(String id) => _items[id]?.quantity ?? 0;

  /// Adds one unit (or whatever is left if less than one is in stock).
  String? add(VegetableEntity v) {
    if (!v.isAvailable || v.stockQuantity <= 0) {
      return '${v.name} is out of stock.';
    }
    if (_items.containsKey(v.id)) return increase(v);
    final qty = v.stockQuantity >= 1 ? 1.0 : v.stockQuantity;
    _items[v.id] = CartItemEntity(
      vegetableId: v.id,
      name: v.name,
      unit: v.unit,
      price: v.price,
      quantity: qty,
    );
    _changed();
    return null;
  }

  /// Cannot go above the available stock.
  String? increase(VegetableEntity v) {
    final current = _items[v.id];
    if (current == null) return add(v);
    if (!v.isAvailable || v.stockQuantity <= 0) {
      return '${v.name} is out of stock.';
    }
    final next = current.quantity + 1;
    if (next > v.stockQuantity) {
      return 'Only ${Formatters.qty(v.stockQuantity)} ${v.unit} of ${v.name} available.';
    }
    _items[v.id] = current.copyWith(price: v.price, quantity: next);
    _changed();
    return null;
  }

  /// Going to zero removes the item.
  void decrease(String id) {
    final current = _items[id];
    if (current == null) return;
    final next = current.quantity - 1;
    if (next <= 0) {
      _items.remove(id);
    } else {
      _items[id] = current.copyWith(quantity: next);
    }
    _changed();
  }

  void remove(String id) {
    if (_items.remove(id) != null) _changed();
  }

  void clear() {
    _items.clear();
    _checkoutId = null;
    notifyListeners();
  }

  /// Used on logout (no notify: it runs while the widget tree builds).
  void reset() {
    _items.clear();
    _checkoutId = null;
  }

  OrderEntity buildOrder({required String shopId, required String shopName}) {
    _checkoutId ??= const Uuid().v4();
    return OrderEntity(
      id: _checkoutId!,
      shopId: shopId,
      shopName: shopName,
      items: _items.values.map((i) => i.toOrderItem()).toList(),
      totalAmount: totalAmount,
      status: AppConstants.orderPending,
      createdAt: DateTime.now(),
    );
  }

  void _changed() {
    _checkoutId = null;
    notifyListeners();
  }
}
