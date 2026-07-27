import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';

import '../../models/user_role.dart';

class AdminManagementException implements Exception {
  const AdminManagementException(this.message);

  final String message;
}

class ManagedUserInput {
  const ManagedUserInput({
    required this.name,
    required this.email,
    required this.role,
    this.category,
    this.location,
    this.experience,
  });

  final String name;
  final String email;
  final UserRole role;
  final String? category;
  final String? location;
  final String? experience;
}

class ManagedUserResult {
  const ManagedUserResult({required this.passwordSetupEmailSent});

  final bool passwordSetupEmailSent;
}

class ServiceCategoryInput {
  const ServiceCategoryInput({
    required this.name,
    required this.iconKey,
    required this.active,
  });

  final String name;
  final String iconKey;
  final bool active;
}

/// Admin-only management operations backed by the app's existing Firebase
/// Auth, users, providers, and serviceCategories data.
///
/// A secondary Firebase Auth instance creates the invited account so the
/// signed-in administrator's own session is never replaced. The primary
/// admin session then writes the role/profile documents under Firestore's
/// admin-only rules and sends the invitee a password-setup email.
class AdminManagementService {
  static AdminManagementService instance = AdminManagementService();

  Future<ManagedUserResult> createManagedUser(ManagedUserInput input) async {
    if (input.role == UserRole.admin) {
      throw const AdminManagementException(
        'Admin accounts must be provisioned through the Team & Roles flow.',
      );
    }

    FirebaseApp? secondaryApp;
    FirebaseAuth? secondaryAuth;
    User? createdUser;
    var profileSaved = false;

    try {
      if (input.role == UserRole.provider) {
        final categories = await FirebaseFirestore.instance
            .collection('serviceCategories')
            .get();
        final requestedCategory = input.category!.trim().toLowerCase();
        final categoryExists = categories.docs.any(
          (doc) =>
              (doc.data()['name'] as String? ?? '').trim().toLowerCase() ==
              requestedCategory,
        );
        if (!categoryExists) {
          throw const AdminManagementException(
            'That service category does not exist. Add it to the catalog first.',
          );
        }
      }

      secondaryApp = await Firebase.initializeApp(
        name: 'admin-user-${DateTime.now().microsecondsSinceEpoch}',
        options: Firebase.app().options,
      );
      secondaryAuth = FirebaseAuth.instanceFor(app: secondaryApp);
      final credential = await secondaryAuth.createUserWithEmailAndPassword(
        email: input.email.trim(),
        password: _temporaryPassword(),
      );
      createdUser = credential.user;
      if (createdUser == null) {
        throw const AdminManagementException(
          'Firebase did not return the created account.',
        );
      }

      final firestore = FirebaseFirestore.instance;
      final batch = firestore.batch();
      final userRef = firestore.collection('users').doc(createdUser.uid);
      batch.set(userRef, {
        'name': input.name.trim(),
        'displayName': input.name.trim(),
        'email': input.email.trim().toLowerCase(),
        'role': input.role.name,
        'createdAt': FieldValue.serverTimestamp(),
        'createdByAdmin': FirebaseAuth.instance.currentUser?.uid,
      });

      if (input.role == UserRole.provider) {
        final providerRef = firestore
            .collection('providers')
            .doc(createdUser.uid);
        batch.set(providerRef, {
          'displayName': input.name.trim(),
          'category': input.category!.trim(),
          'location': input.location!.trim(),
          'experience': input.experience!.trim(),
          'status': 'active',
          'about': '',
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        });
      }

      await batch.commit();
      profileSaved = true;

      var passwordSetupEmailSent = true;
      try {
        await FirebaseAuth.instance.sendPasswordResetEmail(
          email: input.email.trim(),
        );
      } on FirebaseAuthException {
        passwordSetupEmailSent = false;
      }

      return ManagedUserResult(passwordSetupEmailSent: passwordSetupEmailSent);
    } on FirebaseAuthException catch (error) {
      throw AdminManagementException(_authMessage(error));
    } on FirebaseException catch (error) {
      throw AdminManagementException(
        error.message ?? 'Firebase could not save this account.',
      );
    } finally {
      if (!profileSaved && createdUser != null) {
        try {
          await createdUser.delete();
        } catch (_) {
          // Best-effort rollback. A retry with the same email will surface the
          // orphaned Auth record rather than silently creating duplicates.
        }
      }
      if (secondaryAuth != null) {
        try {
          await secondaryAuth.signOut();
        } catch (_) {}
      }
      if (secondaryApp != null) {
        try {
          await secondaryApp.delete();
        } catch (_) {}
      }
    }
  }

  Future<void> createServiceCategory(ServiceCategoryInput input) async {
    try {
      final collection = FirebaseFirestore.instance.collection(
        'serviceCategories',
      );
      final existing = await collection.get();
      final normalizedName = input.name.trim().toLowerCase();
      if (existing.docs.any(
        (doc) =>
            (doc.data()['name'] as String? ?? '').trim().toLowerCase() ==
            normalizedName,
      )) {
        throw const AdminManagementException(
          'A service category with that name already exists.',
        );
      }
      var highestOrder = 0;
      for (final doc in existing.docs) {
        final value =
            int.tryParse(doc.data()['sortOrder']?.toString() ?? '') ?? 0;
        highestOrder = max(highestOrder, value);
      }

      await collection.add({
        'name': input.name.trim(),
        'iconKey': input.iconKey,
        'active': input.active,
        'sortOrder': '${highestOrder + 10}',
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } on FirebaseException catch (error) {
      throw AdminManagementException(
        error.message ?? 'Firebase could not save this category.',
      );
    }
  }

  static String _temporaryPassword() {
    const chars =
        'ABCDEFGHJKLMNPQRSTUVWXYZabcdefghijkmnopqrstuvwxyz23456789!@#';
    final random = Random.secure();
    return List.generate(24, (_) => chars[random.nextInt(chars.length)]).join();
  }

  static String _authMessage(FirebaseAuthException error) {
    return switch (error.code) {
      'email-already-in-use' =>
        'An account already exists for that email address.',
      'invalid-email' => 'Enter a valid email address.',
      'operation-not-allowed' =>
        'Email account creation is disabled in Firebase Authentication.',
      'network-request-failed' =>
        'Network error — check your connection and try again.',
      _ => error.message ?? 'Firebase could not create this account.',
    };
  }
}
