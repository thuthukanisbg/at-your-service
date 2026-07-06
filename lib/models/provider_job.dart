class ProviderJob {
  const ProviderJob({
    required this.title,
    required this.price,
    required this.timeLabel,
    required this.distanceLabel,
    this.id,
    this.customerId,
    this.address,
  });

  final String title;
  final double price;
  final String timeLabel;
  final String distanceLabel;

  /// Firestore booking doc ID — null for the mock jobs used as a fallback
  /// when there's no live Firebase app (widget tests) or the real fetch
  /// errors. Real jobs always carry one.
  final String? id;

  /// The booking's customerId — same null-for-mock caveat as [id]. Needed
  /// to open a messaging conversation from Job Details.
  final String? customerId;

  /// The booking's real address — same null-for-mock caveat as [id].
  final String? address;
}
