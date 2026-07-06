import 'package:flutter/material.dart';

import '../../core/theme/app_tokens.dart';
import '../../core/widgets/detail_screen_header.dart';
import 'customer_search_screen.dart';
import 'customer_service_details_service.dart';

/// "View all" for both Home's "Popular Services" and "Recommended" rows.
///
/// Both currently point at this same real catalog fetch — there's no
/// popularity ranking or recommendation data anywhere in Firestore (no
/// booking-count/rating fields exist yet), so a distinct "recommended"
/// list would have to be fabricated. Showing the same honest full catalog
/// under either title is a deliberate choice, not a shortcut: it's the
/// same principle used elsewhere in this app (e.g. reusing real service
/// data instead of inventing fake ratings).
class CustomerServicesListScreen extends StatefulWidget {
  const CustomerServicesListScreen({super.key, required this.title});

  final String title;

  @override
  State<CustomerServicesListScreen> createState() => _CustomerServicesListScreenState();
}

class _CustomerServicesListScreenState extends State<CustomerServicesListScreen> {
  late final Future<List<SearchableService>> _servicesFuture = fetchSearchableServices();

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 4, 18, 8),
              child: DetailScreenHeader(title: widget.title),
            ),
            Expanded(
              child: FutureBuilder<List<SearchableService>>(
                future: _servicesFuture,
                builder: (context, snapshot) {
                  if (!snapshot.hasData && !snapshot.hasError) {
                    return const Center(child: CircularProgressIndicator(strokeWidth: 2.4));
                  }
                  if (snapshot.hasError) {
                    return Center(
                      child: Text("Couldn't load services.", style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w600, color: tokens.mut)),
                    );
                  }
                  final services = snapshot.data!;
                  if (services.isEmpty) {
                    return Center(
                      child: Text('No services available yet.', style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w600, color: tokens.mut)),
                    );
                  }
                  return ListView.builder(
                    padding: const EdgeInsets.fromLTRB(18, 0, 18, 18),
                    itemCount: services.length,
                    itemBuilder: (context, index) => ServiceResultTile(service: services[index]),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
