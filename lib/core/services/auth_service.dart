import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// Thrown by [AuthService] with a message safe to show the user directly.
class AuthException implements Exception {
  const AuthException(this.message);
  final String message;
}

/// Wraps FirebaseAuth/Firestore behind an overridable instance so widget
/// tests (which pump the whole app and walk through AuthScreen) can stub
/// authentication without a live Firebase app.
class AuthService {
  static AuthService instance = AuthService();

  Future<void> signIn({required String email, required String password}) async {
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(email: email, password: password);
    } on FirebaseAuthException catch (e) {
      throw AuthException(_friendlyMessage(e));
    }
  }

  Future<void> signUp({required String name, required String email, required String password}) async {
    final UserCredential credential;
    try {
      credential = await FirebaseAuth.instance.createUserWithEmailAndPassword(email: email, password: password);
    } on FirebaseAuthException catch (e) {
      throw AuthException(_friendlyMessage(e));
    }
    // Role stays null until the chooser sets it — the deployed rules allow a
    // user to set their own role only while it is still null, and never to
    // change it afterwards. If this write fails the Auth account still
    // exists without a users doc; acceptable while everything downstream is
    // mock data, but revisit (sign out + surface retry) before real data.
    await FirebaseFirestore.instance.collection('users').doc(credential.user!.uid).set({
      'name': name,
      'email': email,
      'role': null,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  static String _friendlyMessage(FirebaseAuthException e) {
    return switch (e.code) {
      'invalid-email' => 'That email address looks invalid.',
      'email-already-in-use' => 'An account already exists for that email — try signing in.',
      'weak-password' => 'Password is too weak — use at least 6 characters.',
      'user-not-found' || 'wrong-password' || 'invalid-credential' => 'Email or password is incorrect.',
      'network-request-failed' => 'Network error — check your connection and try again.',
      _ => 'Something went wrong (${e.code}). Please try again.',
    };
  }
}
