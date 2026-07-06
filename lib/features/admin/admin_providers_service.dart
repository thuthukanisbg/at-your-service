import 'package:cloud_firestore/cloud_firestore.dart';

/// Display shape for one `providers` document — real fields confirmed
/// against live data: displayName, category, location, status, experience
/// (a string, e.g. "3", not a number), about.
class AdminProviderSummary {
  const AdminProviderSummary({
    required this.displayName,
    required this.category,
    required this.location,
    required this.status,
    required this.experience,
  });

  final String displayName;
  final String category;
  final String location;
  final String status;
  final String experience;
}

Future<List<AdminProviderSummary>> fetchProviders() async {
  final snapshot = await FirebaseFirestore.instance.collection('providers').get();

  return snapshot.docs.map((doc) {
    final data = doc.data();
    return AdminProviderSummary(
      displayName: data['displayName'] as String? ?? 'Provider',
      category: data['category'] as String? ?? 'General',
      location: data['location'] as String? ?? '—',
      status: data['status'] as String? ?? 'unknown',
      experience: data['experience']?.toString() ?? '—',
    );
  }).toList();
}
