import 'package:firebase_auth/firebase_auth.dart';
import '../repositories/auth_repository.dart';

class VerifyPhoneUseCase {
  final AuthRepository repo;
  const VerifyPhoneUseCase(this.repo);

  Future<void> call({
    required String phone,
    required void Function(String verificationId, int? resendToken) onCodeSent,
    required void Function(String error) onError,
    required void Function(PhoneAuthCredential credential) onAutoVerified,
  }) =>
      repo.verifyPhoneNumber(
        phone: phone,
        onCodeSent: onCodeSent,
        onError: onError,
        onAutoVerified: onAutoVerified,
      );
}
