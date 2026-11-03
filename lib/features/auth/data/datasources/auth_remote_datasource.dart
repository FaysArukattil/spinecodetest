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

  /// Starts Firebase Phone Number verification.
  Future<void> verifyPhoneNumber({
    required String phone,
    required void Function(String verificationId, int? resendToken) onCodeSent,
    required void Function(String error) onError,
    required void Function(PhoneAuthCredential credential) onAutoVerified,
  }) async {
    final cleanPhone = phone.replaceAll(RegExp(r'\D'), '');
    final formatted = phone.startsWith('+') ? phone : '+91$cleanPhone';
    await _auth.verifyPhoneNumber(
      phoneNumber: formatted,
      timeout: const Duration(seconds: 60),
      verificationCompleted: onAutoVerified,
      verificationFailed: (FirebaseAuthException e) {
        onError(e.message ?? 'Verification failed (${e.code})');
      },
      codeSent: (verificationId, resendToken) {
        onCodeSent(verificationId, resendToken);
      },
      codeAutoRetrievalTimeout: (verificationId) {},
    );
  }

  /// Completes Phone Auth sign-in using verificationId and SMS code.
  Future<UserModel> signInWithPhoneCode({
    required String verificationId,
    required String smsCode,
  }) async {
    final credential = PhoneAuthProvider.credential(
      verificationId: verificationId,
      smsCode: smsCode,
    );
    final cred = await _auth.signInWithCredential(credential);

    // Only registered shops can log in with OTP
    final phoneNum = cred.user?.phoneNumber ?? '';
    final digits = phoneNum.replaceAll(RegExp(r'\D'), '');
    final tenDigit = digits.length >= 10 ? digits.substring(digits.length - 10) : digits;

    if (tenDigit.isNotEmpty) {
      final snap = await _db
          .collection(FirestoreKeys.shops)
          .where(FirestoreKeys.phone, isEqualTo: tenDigit)
          .limit(1)
          .get();
      if (snap.docs.isNotEmpty) {
        final d = snap.docs.first;
        if (d.data()[FirestoreKeys.status] != AppConstants.shopActive) {
          throw const AppException(
            'Your shop has been blocked. Please contact the store.',
          );
        }
        return UserModel(
          id: d.id,
          name: (d.data()[FirestoreKeys.shopName] ?? 'Shop') as String,
          email: (d.data()[FirestoreKeys.email] ?? '') as String,
          role: AppConstants.roleShop,
        );
      }
    }

    throw const AppException(
      'This phone number is not registered with any shop. Please contact the store administrator.',
    );
  }

  /// Verifies that a phone number belongs to an active registered shop before dispatching OTP.
  Future<void> checkShopRegistered(String phone) async {
    final clean = phone.replaceAll(RegExp(r'\D'), '');
    final tenDigit = clean.length >= 10 ? clean.substring(clean.length - 10) : clean;
    if (tenDigit.length < 10) {
      throw const AppException('Please enter a valid 10-digit mobile number.');
    }
    final snap = await _db
        .collection(FirestoreKeys.shops)
        .where(FirestoreKeys.phone, isEqualTo: tenDigit)
        .limit(1)
        .get();
    if (snap.docs.isEmpty) {
      throw const AppException(
        'This mobile number is not registered with any shop. Please contact the store administrator.',
      );
    }
    final d = snap.docs.first;
    if (d.data()[FirestoreKeys.status] != AppConstants.shopActive) {
      throw const AppException(
        'Your shop has been blocked. Please contact the store.',
      );
    }
  }

  /// Demo login when phone provider is not yet enabled in Firebase Console.
  Future<UserModel> demoLoginWithPhone(String phone) async {
    final clean = phone.replaceAll(RegExp(r'\D'), '');
    final tenDigit = clean.length >= 10 ? clean.substring(clean.length - 10) : clean;

    if (tenDigit.isNotEmpty) {
      final snap = await _db
          .collection(FirestoreKeys.shops)
          .where(FirestoreKeys.phone, isEqualTo: tenDigit)
          .limit(1)
          .get();
      if (snap.docs.isNotEmpty) {
        final d = snap.docs.first;
        if (d.data()[FirestoreKeys.status] != AppConstants.shopActive) {
          throw const AppException(
            'Your shop has been blocked. Please contact the store.',
          );
        }
        return UserModel(
          id: d.id,
          name: (d.data()[FirestoreKeys.shopName] ?? 'Shop') as String,
          email: (d.data()[FirestoreKeys.email] ?? '') as String,
          role: AppConstants.roleShop,
        );
      }
    }

    throw const AppException(
      'This phone number is not registered with any shop. Please contact the store administrator.',
    );
  }

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
