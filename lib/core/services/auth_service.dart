import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../models/user_role.dart';

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

  /// The signed-in user's already-saved role, if any — checked right after
  /// sign-in/sign-up so a returning user who already picked a role skips
  /// RoleSelectScreen. Null covers every case the caller should treat the
  /// same way (fall back to RoleSelectScreen): not signed in, no users doc
  /// yet, `role` still null, an unrecognized value, or the read failing
  /// outright (e.g. no live Firebase app, offline).
  Future<UserRole?> fetchSavedRole() async {
    try {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid == null) return null;
      final doc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
      return switch (doc.data()?['role']) {
        'customer' => UserRole.customer,
        'provider' => UserRole.provider,
        'admin' => UserRole.admin,
        _ => null,
      };
    } catch (_) {
      return null;
    }
  }

  Future<void> signOut() => FirebaseAuth.instance.signOut();

  /// Sends an SMS verification code to [phoneNumber]. On web (this app's
  /// only tested platform), FirebaseAuth handles the reCAPTCHA challenge
  /// itself with an invisible widget when no [RecaptchaVerifier] is passed.
  Future<ConfirmationResult> sendPhoneVerificationCode(String phoneNumber) async {
    try {
      return await FirebaseAuth.instance.signInWithPhoneNumber(phoneNumber);
    } on FirebaseAuthException catch (e) {
      throw AuthException(_friendlyMessage(e));
    }
  }

  /// Confirms the code sent by [sendPhoneVerificationCode]. Same
  /// role:null-on-first-sign-up behavior as [signUp] — a brand-new phone
  /// user gets a `users/{uid}` doc; a returning one doesn't need one
  /// rewritten.
  Future<void> confirmPhoneCode({required ConfirmationResult confirmation, required String smsCode}) async {
    final UserCredential credential;
    try {
      credential = await confirmation.confirm(smsCode);
    } on FirebaseAuthException catch (e) {
      throw AuthException(_friendlyMessage(e));
    }
    if (credential.additionalUserInfo?.isNewUser ?? false) {
      final user = credential.user!;
      await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
        'name': user.phoneNumber ?? 'New user',
        'phoneNumber': user.phoneNumber,
        'role': null,
        'createdAt': FieldValue.serverTimestamp(),
      });
    }
  }

  static String _friendlyMessage(FirebaseAuthException e) {
    return switch (e.code) {
      'invalid-email' => 'That email address looks invalid.',
      'email-already-in-use' => 'An account already exists for that email — try signing in.',
      'weak-password' => 'Password is too weak — use at least 6 characters.',
      'user-not-found' || 'wrong-password' || 'invalid-credential' => 'Email or password is incorrect.',
      'network-request-failed' => 'Network error — check your connection and try again.',
      'invalid-phone-number' => 'That phone number looks invalid.',
      'too-many-requests' => 'Too many attempts — please wait a bit and try again.',
      'invalid-verification-code' => 'That code is incorrect. Please try again.',
      'code-expired' || 'session-expired' => 'That code expired — request a new one.',
      _ => 'Something went wrong (${e.code}). Please try again.',
    };
  }
}
