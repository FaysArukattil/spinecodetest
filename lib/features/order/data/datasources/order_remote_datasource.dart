import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/constants/firestore_keys.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/utils/formatters.dart';
import '../models/order_item_model.dart';
import '../models/order_model.dart';

class OrderRemoteDataSource {
  final FirebaseFirestore _db;
  OrderRemoteDataSource({FirebaseFirestore? db})
      : _db = db ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _orders =>
      _db.collection(FirestoreKeys.orders);
  CollectionReference<Map<String, dynamic>> get _vegs =>
      _db.collection(FirestoreKeys.vegetables);

  // Allowed status changes. Anything else is rejected.
  static const _transitions = <String, List<String>>{
    AppConstants.orderPending: [
      AppConstants.orderApproved,
      AppConstants.orderRejected,
      AppConstants.orderCancelled,
    ],
    AppConstants.orderApproved: [AppConstants.orderCompleted],
  };

  Stream<List<OrderModel>> watchAll() =>
      _orders.snapshots().map(_toSortedList);

  // No orderBy here: avoids needing a composite index; sorted on the client.
  Stream<List<OrderModel>> watchByShop(String shopId) => _orders
      .where(FirestoreKeys.shopId, isEqualTo: shopId)
      .snapshots()
      .map(_toSortedList);

  List<OrderModel> _toSortedList(QuerySnapshot<Map<String, dynamic>> snap) {
    final list = snap.docs.map(OrderModel.fromDoc).toList();
    list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return list;
  }

  /// One transaction: check stock -> deduct stock -> create order.
  /// If the order id already exists the call is ignored (duplicate submit).
  Future<void> placeOrder(OrderModel order) {
    return _db.runTransaction((tx) async {
      final orderRef = _orders.doc(order.id);
      final existing = await tx.get(orderRef);
      if (existing.exists) return;

      // all reads first
      final refs = order.items.map((i) => _vegs.doc(i.vegetableId)).toList();
      final snaps = <DocumentSnapshot<Map<String, dynamic>>>[];
      for (final r in refs) {
        snaps.add(await tx.get(r));
      }

      final stocks = <double>[];
      for (var i = 0; i < order.items.length; i++) {
        final item = order.items[i];
        final data = snaps[i].data();
        if (!snaps[i].exists || data == null) {
          throw AppException('${item.name} is no longer available.');
        }
        if (data[FirestoreKeys.status] != AppConstants.vegAvailable) {
          throw AppException('${item.name} is out of stock.');
        }
        final stock = ((data[FirestoreKeys.stockQuantity] ?? 0) as num).toDouble();
        if (item.quantity <= 0) {
          throw AppException('Invalid quantity for ${item.name}.');
        }
        if (item.quantity > stock) {
          throw AppException(
              'Only ${Formatters.qty(stock)} ${item.unit} of ${item.name} available.');
        }
        stocks.add(stock);
      }

      // then writes
      for (var i = 0; i < order.items.length; i++) {
        final left = stocks[i] - order.items[i].quantity;
        tx.update(refs[i], {
          FirestoreKeys.stockQuantity: left,
          if (left <= 0) FirestoreKeys.status: AppConstants.vegOutOfStock,
        });
      }
      tx.set(orderRef, order.toMap());
    });
  }

  /// Validates the transition, and gives the stock back when a Pending order
  /// is Rejected or Cancelled.
  Future<void> updateStatus(String orderId, String newStatus) {
    return _db.runTransaction((tx) async {
      final ref = _orders.doc(orderId);
      final snap = await tx.get(ref);
      if (!snap.exists) throw const AppException('Order not found.');
      final order = OrderModel.fromDoc(snap);
      final old = order.status;

      final allowed = _transitions[old] ?? const <String>[];
      if (!allowed.contains(newStatus)) {
        if (newStatus == AppConstants.orderCancelled) {
          throw AppException(
              'This order is $old and can no longer be cancelled. Only Pending orders can be cancelled.');
        }
        throw AppException('Order is already $old.');
      }

      final restock = old == AppConstants.orderPending &&
          (newStatus == AppConstants.orderRejected ||
              newStatus == AppConstants.orderCancelled);

      if (restock) {
        final refs = order.items.map((i) => _vegs.doc(i.vegetableId)).toList();
        final snaps = <DocumentSnapshot<Map<String, dynamic>>>[];
        for (final r in refs) {
          snaps.add(await tx.get(r));
        }
        for (var i = 0; i < refs.length; i++) {
          final data = snaps[i].data();
          if (!snaps[i].exists || data == null) continue; // vegetable was deleted
          final current =
              ((data[FirestoreKeys.stockQuantity] ?? 0) as num).toDouble();
          tx.update(refs[i], {
            FirestoreKeys.stockQuantity: current + order.items[i].quantity,
            // auto "Out of Stock" items come back as Available
            if (current <= 0) FirestoreKeys.status: AppConstants.vegAvailable,
          });
        }
      }

      tx.update(ref, {FirestoreKeys.status: newStatus});
    });
  }

  /// Updates items and totalAmount of an order (e.g. store edits pending order).
  Future<void> updateOrderItems(String orderId, List<OrderItemModel> items) async {
    final double total = items.fold(0.0, (acc, i) => acc + i.lineTotal);
    await _orders.doc(orderId).update({
      FirestoreKeys.items: items.map((i) => i.toMap()).toList(),
      FirestoreKeys.totalAmount: total,
    });
  }
}
