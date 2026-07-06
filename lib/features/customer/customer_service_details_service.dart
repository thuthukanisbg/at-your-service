import 'package:cloud_firestore/cloud_firestore.dart';

/// A real `services` document, shaped for [ServiceDetailsScreen] display.
class RealServiceDetails {
  const RealServiceDetails({
    required this.id,
    required this.title,
    required this.description,
    required this.basePrice,
    required this.durationLabel,
    required this.includedItems,
  });

  /// Real Firestore `services` doc ID — used to reference the actual
  /// service when creating a booking, rather than the short category-slug
  /// style seen in some historical booking docs (e.g. "electrical"), which
  /// don't correspond to any doc in the current `services` collection.
  final String id;
  final String title;
  final String description;

  /// Real docs store this as either a string or a number — already coerced
  /// to `num` by the fetch functions below.
  final num basePrice;
  final String durationLabel;
  final List<String> includedItems;
}

/// Lightweight shape for the search/filter results list — just enough to
/// render a row and pick a service, not the full detail page.
class SearchableService {
  const SearchableService({
    required this.id,
    required this.name,
    required this.categoryId,
    required this.basePrice,
  });

  final String id;
  final String name;
  final String categoryId;
  final num basePrice;
}

RealServiceDetails _toServiceDetails(String id, Map<String, dynamic> data) {
  // basePrice is a string in most existing docs but a raw number in at
  // least one (a QA-created service) — handle both, default to 0.
  final rawPrice = data['basePrice'];
  final basePrice = rawPrice is num ? rawPrice : (num.tryParse(rawPrice?.toString() ?? '') ?? 0);

  // estimatedDurationMinutes has the same string/number inconsistency.
  final durationMinutes = int.tryParse(data['estimatedDurationMinutes']?.toString() ?? '');
  final durationLabel = switch (durationMinutes) {
    null => '—',
    < 60 => '$durationMinutes mins',
    _ => durationMinutes % 60 == 0
        ? '${durationMinutes ~/ 60} hrs'
        : '${(durationMinutes / 60).toStringAsFixed(1)} hrs',
  };

  final checklist = (data['checklistTemplate'] as List<dynamic>? ?? [])
      .whereType<Map<String, dynamic>>()
      .map((item) => item['label'] as String? ?? '')
      .where((label) => label.isNotEmpty)
      .toList();

  return RealServiceDetails(
    id: id,
    title: data['name'] as String? ?? 'Service',
    description: data['description'] as String? ?? '',
    basePrice: basePrice,
    durationLabel: durationLabel,
    includedItems: checklist,
  );
}

/// Fetches one representative active service to display — used when
/// ServiceDetailsScreen is opened without a specific serviceId (category
/// tap, promo tap, recommended card). Picks the first active service by
/// `sortOrder`, sorted client-side: `sortOrder` is stored as a string in
/// the real data, so a Firestore-side sort would be lexicographic, and
/// pairing it with `where('active', ...)` would need an undeployed
/// composite index.
Future<RealServiceDetails?> fetchFeaturedService() async {
  final snapshot = await FirebaseFirestore.instance
      .collection('services')
      .where('active', isEqualTo: true)
      .get();

  if (snapshot.docs.isEmpty) return null;

  final docs = snapshot.docs.toList()
    ..sort((a, b) {
      final aOrder = int.tryParse(a.data()['sortOrder']?.toString() ?? '') ?? 0;
      final bOrder = int.tryParse(b.data()['sortOrder']?.toString() ?? '') ?? 0;
      return aOrder.compareTo(bOrder);
    });

  return _toServiceDetails(docs.first.id, docs.first.data());
}

/// Fetches one specific service by its Firestore doc ID — used when
/// ServiceDetailsScreen is opened from a search/filter result.
Future<RealServiceDetails?> fetchServiceById(String id) async {
  final doc = await FirebaseFirestore.instance.collection('services').doc(id).get();
  if (!doc.exists) return null;
  return _toServiceDetails(doc.id, doc.data()!);
}

/// Fetches every active service, for client-side search/filter — the
/// dataset is small enough (a handful of docs) that filtering locally is
/// simpler and safer than trying to do substring search server-side
/// (Firestore has no native "contains" query).
Future<List<SearchableService>> fetchSearchableServices() async {
  final snapshot = await FirebaseFirestore.instance
      .collection('services')
      .where('active', isEqualTo: true)
      .get();

  return snapshot.docs.map((doc) {
    final data = doc.data();
    final rawPrice = data['basePrice'];
    final basePrice = rawPrice is num ? rawPrice : (num.tryParse(rawPrice?.toString() ?? '') ?? 0);
    return SearchableService(
      id: doc.id,
      name: data['name'] as String? ?? 'Service',
      categoryId: data['categoryId'] as String? ?? '',
      basePrice: basePrice,
    );
  }).toList();
}
