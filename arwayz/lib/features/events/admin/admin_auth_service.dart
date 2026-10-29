import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// Raised for sign-in problems an admin should see worded plainly.
class AdminAuthException implements Exception {
  final String message;
  const AdminAuthException(this.message);

  @override
  String toString() => message;
}

/// Firebase sign-in for the admin portal.
///
/// An account only counts as an administrator when a document exists at
/// `admins/{uid}`. The Firestore rules check exactly the same thing, so this
/// is a convenience for the UI rather than the security boundary.
///
/// Note this shares [FirebaseAuth.instance] with the student sign-in used for
/// comments and likes. Firebase keeps a single session per app, so signing in
/// here replaces any signed-in student; the gate warns about that before it
/// happens.
class AdminAuthService {
  AdminAuthService({FirebaseAuth? auth, FirebaseFirestore? firestore})
      : _auth = auth ?? FirebaseAuth.instance,
        _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  static const String adminsCollection = 'admins';

  User? get currentUser => _auth.currentUser;

  Stream<User?> authStateChanges() => _auth.authStateChanges();

  /// True when the signed-in account is on the admin allowlist.
  Future<bool> isAdmin(String uid) async {
    try {
      final doc = await _firestore.collection(adminsCollection).doc(uid).get();
      return doc.exists;
    } catch (_) {
      // A permission error here means the account is not an admin, since the
      // rules only let an admin read their own allowlist document.
      return false;
    }
  }

  /// Signs in and verifies the allowlist.
  ///
  /// A valid Firebase account that is not an admin is signed straight back
  /// out, so a student account cannot linger in the portal.
  Future<void> signIn({
    required String email,
    required String password,
  }) async {
    UserCredential credential;
    try {
      credential = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
    } on FirebaseAuthException catch (error) {
      throw AdminAuthException(_describe(error));
    }

    final uid = credential.user?.uid;
    if (uid == null || !await isAdmin(uid)) {
      await _auth.signOut();
      throw const AdminAuthException(
        'This account is not an administrator.',
      );
    }
  }

  Future<void> signOut() => _auth.signOut();

  String _describe(FirebaseAuthException error) {
    switch (error.code) {
      case 'invalid-email':
        return 'That email address is not valid.';
      case 'invalid-credential':
      case 'wrong-password':
      case 'user-not-found':
        return 'Incorrect email or password.';
      case 'user-disabled':
        return 'This account has been disabled.';
      case 'too-many-requests':
        return 'Too many attempts. Wait a moment and try again.';
      case 'network-request-failed':
        return 'Network error. Check your connection.';
      case 'operation-not-allowed':
        return 'Email sign-in is not enabled for this project yet.';
      default:
        return error.message ?? 'Sign-in failed. Try again.';
    }
  }
}
