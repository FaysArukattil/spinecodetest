import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/constants/firestore_keys.dart';
import '../../../../core/errors/exceptions.dart';
import '../models/user_model.dart';

class AuthRemoteDataSource {
  final FirebaseAuth _auth;
  final FirebaseFirestore _db;

  AuthRemoteDataSource({FirebaseAuth? auth, FirebaseFirestore? db})
    : _auth = auth ?? FirebaseAuth.instance,
      _db = db ?? FirebaseFirestore.instance;

  bool get hasUser => _auth.currentUser != null;

  Future<UserModel> login(String email, String password) async {
    final cred = await _auth.signInWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
    try {
      return await _loadUser(cred.user!.uid);
    } catch (e) {
      await _auth.signOut(); // never leave a half-valid session behind
      rethrow;
    }
  }

  Future<UserModel?> restore() async {
    final user = _auth.currentUser;
    if (user == null) return null;
    return _loadUser(user.uid);
  }

  Future<void> logout() => _auth.signOut();

  /// Loads the user profile and enforces: valid role + shop must be Active.
  Future<UserModel> _loadUser(String uid) async {
    final doc = await _db.collection(FirestoreKeys.users).doc(uid).get();
    if (!doc.exists || doc.data() == null) {
      throw const AppException('Account is not registered in the system.');
    }
    final user = UserModel.fromMap(doc.id, doc.data()!);

    if (user.role != AppConstants.roleStore &&
        user.role != AppConstants.roleShop) {
      throw const AppException('Invalid account role.');
    }

    if (user.isShop) {
      final shop = await _db.collection(FirestoreKeys.shops).doc(uid).get();
      if (!shop.exists) {
        throw const AppException('Shop account not found.');
      }
      if (shop.data()?[FirestoreKeys.status] != AppConstants.shopActive) {
        throw const AppException(
          'Your shop has been blocked. Please contact the store.',
        );
      }
    }
    return user;
  }
}
