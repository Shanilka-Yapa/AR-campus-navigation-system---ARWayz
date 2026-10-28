import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/student_profile.dart';

/// Raised for problems a student should see worded plainly.
class StudentAuthException implements Exception {
  final String message;
  const StudentAuthException(this.message);

  @override
  String toString() => message;
}

/// Sign-up, sign-in and profile lookup for students.
///
/// Registering creates the Firebase Auth account immediately but puts the
/// student in `pending`; they can sign in and browse, yet the Firestore rules
/// refuse their comments and likes until an admin approves them.
class StudentAuthService {
  StudentAuthService({FirebaseAuth? auth, FirebaseFirestore? firestore})
      : _auth = auth ?? FirebaseAuth.instance,
        _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  static const String studentsCollection = 'students';

  User? get currentUser => _auth.currentUser;

  /// Emits whenever the student signs in or out.
  Stream<User?> authStateChanges() => _auth.authStateChanges();

  /// Live view of the signed-in student's profile, so an approval or a block
  /// applied by an admin takes effect without restarting the app.
  Stream<StudentProfile?> watchProfile(String uid) {
    return _firestore
        .collection(studentsCollection)
        .doc(uid)
        .snapshots()
        .map((doc) {
      final data = doc.data();
      if (data == null) return null;
      return StudentProfile.fromFirestore(doc.id, data);
    });
  }

  Future<void> register({
    required String name,
    required String indexNumber,
    required String email,
    required String password,
  }) async {
    UserCredential credential;
    try {
      credential = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
    } on FirebaseAuthException catch (error) {
      throw StudentAuthException(_describeAuthError(error));
    }

    final uid = credential.user?.uid;
    if (uid == null) {
      throw const StudentAuthException('Registration failed. Try again.');
    }

    try {
      await _firestore.collection(studentsCollection).doc(uid).set({
        'name': name.trim(),
        'indexNumber': indexNumber.trim(),
        'email': email.trim(),
        // The rules only accept 'pending' here; an admin moves it onward.
        'status': 'pending',
        'createdAt': FieldValue.serverTimestamp(),
      });
    } catch (error) {
      // The account exists but has no profile, which would leave the student
      // permanently stuck. Sign out so they can be helped, and say so.
      await _auth.signOut();
      throw StudentAuthException(
        'Your account was created but the registration details could not be '
        'saved ($error). Ask an admin for help before signing in again.',
      );
    }
  }

  Future<void> signIn({
    required String email,
    required String password,
  }) async {
    try {
      await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
    } on FirebaseAuthException catch (error) {
      throw StudentAuthException(_describeAuthError(error));
    }
  }

  Future<void> signOut() => _auth.signOut();

  String _describeAuthError(FirebaseAuthException error) {
    switch (error.code) {
      case 'email-already-in-use':
        return 'An account already exists for that email. Sign in instead.';
      case 'invalid-email':
        return 'That email address is not valid.';
      case 'weak-password':
        return 'Choose a password of at least 6 characters.';
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
        return error.message ?? 'Something went wrong. Try again.';
    }
  }
}
