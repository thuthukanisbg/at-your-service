import 'package:cloud_firestore/cloud_firestore.dart';

class AdminTeamMember {
  const AdminTeamMember({required this.name, required this.email});
  final String name;
  final String email;
}

/// Real admin users — `users/{uid}` docs with `role == 'admin'`. This is the
/// minimal, honest slice: this app has exactly one `role` field with three
/// values (customer/provider/admin, see `firestore.rules`'s `isAdmin()`) and
/// no concept of admin sub-roles, no login-tracking field on any user doc,
/// and no invite mechanism (sign-up is self-service via the public Auth
/// screen). So this deliberately returns only name/email — no Role, no Last
/// Active, no Status/Invited: there's nothing real behind any of those.
Future<List<AdminTeamMember>> fetchAdminTeamMembers() async {
  final snapshot = await FirebaseFirestore.instance
      .collection('users')
      .where('role', isEqualTo: 'admin')
      .get();

  return snapshot.docs.map((doc) {
    final data = doc.data();
    final displayName = data['displayName'] as String?;
    final legacyName = data['name'] as String?;
    final email = data['email'] as String?;
    final name = (displayName != null && displayName.isNotEmpty)
        ? displayName
        : (legacyName != null && legacyName.isNotEmpty ? legacyName : (email ?? 'Admin'));
    return AdminTeamMember(name: name, email: email ?? '—');
  }).toList();
}
