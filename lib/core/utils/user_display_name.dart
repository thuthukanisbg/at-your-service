import 'package:cloud_firestore/cloud_firestore.dart';

/// Resolves a display-worthy label for a user from their `users/{uid}` doc.
/// Real docs use `displayName`; ones created via this app's own sign-up
/// flow use `name` — checks both, then falls back to `email`/`phoneNumber`
/// since no sign-up flow here actually collects a real name yet, so most
/// live accounts have neither `displayName` nor `name` populated. Returns
/// null (not a fallback string) only when the doc is missing/unreadable,
/// so callers can supply their own context-appropriate fallback.
Future<String?> fetchUserDisplayName(String uid) async {
  try {
    final doc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
    final data = doc.data();
    final displayName = data?['displayName'] as String?;
    final legacyName = data?['name'] as String?;
    final email = data?['email'] as String?;
    final phone = data?['phoneNumber'] as String?;
    if (displayName != null && displayName.isNotEmpty) return displayName;
    if (legacyName != null && legacyName.isNotEmpty) return legacyName;
    if (email != null && email.isNotEmpty) return email;
    if (phone != null && phone.isNotEmpty) return phone;
    return null;
  } catch (_) {
    return null;
  }
}
