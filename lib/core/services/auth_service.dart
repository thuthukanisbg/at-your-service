import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

import '../../models/user_role.dart';

/// Thrown by [AuthService] with a message safe to show the user directly.
class AuthException implements Exception {
  const AuthException(this.message);
  final String message;
}

/// Cross-platform handle for the second step of phone authentication.
///
/// Firebase uses [ConfirmationResult] on web and a verification ID plus
/// [PhoneAuthCredential] on Android/iOS. Keeping that distinction here lets
/// the authentication UI stay shared across all three platforms.
abstract class PhoneVerificationSession {
  bool get isAlreadyVerified;

  Future<UserCredential> confirm(String smsCode);
}

class _WebPhoneVerificationSession implements PhoneVerificationSession {
  const _WebPhoneVerificationSession(this.confirmation);

  final ConfirmationResult confirmation;

  @override
  bool get isAlreadyVerified => false;

  @override
  Future<UserCredential> confirm(String smsCode) =>
      confirmation.confirm(smsCode);
}

class _NativePhoneVerificationSession implements PhoneVerificationSession {
  const _NativePhoneVerificationSession(this.auth, this.verificationId);

  final FirebaseAuth auth;
  final String verificationId;

  @override
  bool get isAlreadyVerified => false;

  @override
  Future<UserCredential> confirm(String smsCode) {
    final credential = PhoneAuthProvider.credential(
      verificationId: verificationId,
      smsCode: smsCode,
    );
    return auth.signInWithCredential(credential);
  }
}

class _CompletedPhoneVerificationSession implements PhoneVerificationSession {
  const _CompletedPhoneVerificationSession(this.credential);

  final UserCredential credential;

  @override
  bool get isAlreadyVerified => true;

  @override
  Future<UserCredential> confirm(String smsCode) async => credential;
}

/// Wraps FirebaseAuth/Firestore behind an overridable instance so widget
/// tests (which pump the whole app and walk through AuthScreen) can stub
/// authentication without a live Firebase app.
class AuthService {
  static AuthService instance = AuthService();

  Future<void> signIn({required String email, required String password}) async {
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      throw AuthException(_friendlyMessage(e));
    }
  }

  Future<void> signUp({
    required String name,
    required String email,
    required String password,
  }) async {
    final UserCredential credential;
    try {
      credential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      throw AuthException(_friendlyMessage(e));
    }
    // Role stays null until the chooser sets it — the deployed rules allow a
    // user to set their own role only while it is still null, and never to
    // change it afterwards. If this write fails the Auth account still
    // exists without a users doc; acceptable while everything downstream is
    // mock data, but revisit (sign out + surface retry) before real data.
    await FirebaseFirestore.instance
        .collection('users')
        .doc(credential.user!.uid)
        .set({
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
      final doc =
          await FirebaseFirestore.instance.collection('users').doc(uid).get();
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

  /// Sends an SMS verification code using the API Firebase supports on the
  /// current platform: reCAPTCHA-backed [FirebaseAuth.signInWithPhoneNumber]
  /// on web and [FirebaseAuth.verifyPhoneNumber] on Android/iOS.
  Future<PhoneVerificationSession> sendPhoneVerificationCode(
    String phoneNumber,
  ) async {
    final auth = FirebaseAuth.instance;
    try {
      if (kIsWeb) {
        final confirmation = await auth.signInWithPhoneNumber(phoneNumber);
        return _WebPhoneVerificationSession(confirmation);
      }
      if (defaultTargetPlatform != TargetPlatform.android &&
          defaultTargetPlatform != TargetPlatform.iOS) {
        throw const AuthException(
          'Phone sign-in is available on Android, iOS, and web.',
        );
      }

      final completer = Completer<PhoneVerificationSession>();
      await auth.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        verificationCompleted: (credential) async {
          // If codeSent already completed the session, keep the UI on the
          // explicit code path instead of silently signing in behind it.
          if (completer.isCompleted) return;
          try {
            final userCredential = await auth.signInWithCredential(credential);
            if (!completer.isCompleted) {
              completer.complete(
                _CompletedPhoneVerificationSession(userCredential),
              );
            }
          } on FirebaseAuthException catch (e) {
            if (!completer.isCompleted) {
              completer.completeError(AuthException(_friendlyMessage(e)));
            }
          }
        },
        verificationFailed: (e) {
          if (!completer.isCompleted) {
            completer.completeError(AuthException(_friendlyMessage(e)));
          }
        },
        codeSent: (verificationId, _) {
          if (!completer.isCompleted) {
            completer.complete(
              _NativePhoneVerificationSession(auth, verificationId),
            );
          }
        },
        codeAutoRetrievalTimeout: (_) {},
      );
      return await completer.future;
    } on FirebaseAuthException catch (e) {
      throw AuthException(_friendlyMessage(e));
    }
  }

  /// Finishes phone sign-in and creates the same role-null profile used by
  /// email sign-up for a brand-new account.
  Future<void> confirmPhoneCode({
    required PhoneVerificationSession session,
    required String smsCode,
  }) async {
    final UserCredential credential;
    try {
      credential = await session.confirm(smsCode);
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
      'email-already-in-use' =>
        'An account already exists for that email — try signing in.',
      'weak-password' => 'Password is too weak — use at least 6 characters.',
      'user-not-found' ||
      'wrong-password' ||
      'invalid-credential' => 'Email or password is incorrect.',
      'network-request-failed' =>
        'Network error — check your connection and try again.',
      'invalid-phone-number' => 'That phone number looks invalid.',
      'too-many-requests' =>
        'Too many attempts — please wait a bit and try again.',
      'invalid-verification-code' =>
        'That code is incorrect. Please try again.',
      'code-expired' ||
      'session-expired' => 'That code expired — request a new one.',
      _ => 'Something went wrong (${e.code}). Please try again.',
    };
  }
}
