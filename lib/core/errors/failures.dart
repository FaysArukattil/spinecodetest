import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'exceptions.dart';

class Failure {
  final String message;
  const Failure(this.message);

  /// Turns any thrown error into a user-friendly Failure.
  factory Failure.from(Object e) {
    if (e is AppException) return Failure(e.message);
    if (e is FirebaseAuthException) {
      switch (e.code) {
        case 'invalid-email':
          return const Failure('Invalid email address.');
        case 'user-not-found':
        case 'wrong-password':
        case 'invalid-credential':
          return const Failure('Incorrect email or password.');
        case 'user-disabled':
          return const Failure('This account has been disabled.');
        case 'too-many-requests':
          return const Failure('Too many attempts. Try again later.');
        case 'network-request-failed':
          return const Failure('No internet connection.');
        case 'email-already-in-use':
          return const Failure('This email is already registered.');
        case 'weak-password':
          return const Failure('Password is too weak (min 6 characters).');
        default:
          return Failure(e.message ?? 'Authentication failed.');
      }
    }
    if (e is FirebaseException) {
      switch (e.code) {
        case 'permission-denied':
          return const Failure('You do not have permission to do this.');
        case 'unavailable':
          return const Failure('No internet connection.');
        default:
          return Failure(e.message ?? 'Something went wrong.');
      }
    }
    return const Failure('Something went wrong. Please try again.');
  }
}
