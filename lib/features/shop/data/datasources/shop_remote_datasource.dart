import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/constants/firestore_keys.dart';
import '../models/shop_model.dart';

class ShopRemoteDataSource {
  final FirebaseFirestore _db;
  ShopRemoteDataSource({FirebaseFirestore? db})
      : _db = db ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _shops =>
      _db.collection(FirestoreKeys.shops);
  CollectionReference<Map<String, dynamic>> get _users =>
      _db.collection(FirestoreKeys.users);

  Stream<List<ShopModel>> watchAll() => _shops.snapshots().map((snap) {
        final list = snap.docs.map(ShopModel.fromDoc).toList();
        list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        return list;
      });

  Future<void> add(ShopModel shop, String password) async {
    final uid = await _createAuthUser(shop.email, password);
    final batch = _db.batch();
    batch.set(_shops.doc(uid), shop.toMap());
    batch.set(_users.doc(uid), {
      FirestoreKeys.role: AppConstants.roleShop,
      FirestoreKeys.email: shop.email,
      FirestoreKeys.name: shop.shopName,
      FirestoreKeys.createdAt: Timestamp.fromDate(shop.createdAt),
    });
    await batch.commit();
  }

  Future<void> update(ShopModel shop) async {
    final batch = _db.batch();
    batch.update(_shops.doc(shop.id), shop.toMap());
    batch.update(_users.doc(shop.id), {FirestoreKeys.name: shop.shopName});
    await batch.commit();
  }

  /// Removes the shop's data. Its Auth account can no longer log in because
  /// the login flow requires a users/{uid} document.
  Future<void> delete(String id) async {
    final batch = _db.batch();
    batch.delete(_shops.doc(id));
    batch.delete(_users.doc(id));
    await batch.commit();
  }

  Future<void> setStatus(String id, String status) =>
      _shops.doc(id).update({FirestoreKeys.status: status});

  /// Creating a user on the main FirebaseAuth instance would sign the admin
  /// out, so a secondary Firebase app is used just for this call.
  Future<String> _createAuthUser(String email, String password) async {
    FirebaseApp app;
    try {
      app = Firebase.app('shopCreator');
    } catch (_) {
      app = await Firebase.initializeApp(
        name: 'shopCreator',
        options: Firebase.app().options,
      );
    }
    final auth = FirebaseAuth.instanceFor(app: app);
    try {
      final cred = await auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      return cred.user!.uid;
    } finally {
      await auth.signOut();
    }
  }
}
