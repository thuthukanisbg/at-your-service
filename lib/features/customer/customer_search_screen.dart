import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_tokens.dart';
import '../../core/utils/currency.dart';
import '../../core/widgets/detail_screen_header.dart';
import 'customer_service_details_service.dart';
import 'service_details_screen.dart';

/// Real search over active services, with an optional category filter.
/// Firestore has no native substring "contains" query, and the dataset is
/// small, so this fetches all active services once and filters client-side
/// — same pragmatic choice made for sortOrder elsewhere in this codebase.
class CustomerSearchScreen extends StatefulWidget {
  const CustomerSearchScreen({super.key, this.initialCategoryId, this.initialCategoryName});

  final String? initialCategoryId;
  final String? initialCategoryName;

  @override
  State<CustomerSearchScreen> createState() => _CustomerSearchScreenState();
}

class _CustomerSearchScreenState extends State<CustomerSearchScreen> {
  late final Future<List<SearchableService>> _servicesFuture = fetchSearchableServices();
  final _controller = TextEditingController();
  String _query = '';
  String? _categoryFilter;

  @override
  void initState() {
    super.initState();
    _categoryFilter = widget.initialCategoryId;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 4, 18, 8),
              child: const DetailScreenHeader(title: 'Search'),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18),
              child: Container(
                height: 48,
                padding: const EdgeInsets.symmetric(horizontal: 14),
                decoration: BoxDecoration(
                  color: tokens.card,
                  border: Border.all(color: tokens.line),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  children: [
                    Icon(LucideIcons.search, size: 18, color: tokens.mut),
                    const SizedBox(width: 9),
                    Expanded(
                      child: TextField(
                        controller: _controller,
                        autofocus: widget.initialCategoryId == null,
                        onChanged: (value) => setState(() => _query = value),
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: tokens.tx),
                        decoration: InputDecoration(
                          isCollapsed: true,
                          border: InputBorder.none,
                          hintText: 'Search for a service…',
                          hintStyle: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: tokens.mut),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (_categoryFilter != null)
              Padding(
                padding: const EdgeInsets.fromLTRB(18, 10, 18, 0),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: InputChip(
                    label: Text(widget.initialCategoryName ?? 'Filtered'),
                    onDeleted: () => setState(() => _categoryFilter = null),
                    backgroundColor: AppColors.primary.withValues(alpha: 0.12),
                    labelStyle: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700, color: AppColors.primary),
                    deleteIconColor: AppColors.primary,
                    side: BorderSide.none,
                  ),
                ),
              ),
            const SizedBox(height: 8),
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
                  final query = _query.trim().toLowerCase();
                  final results = snapshot.data!.where((service) {
                    final matchesQuery = query.isEmpty || service.name.toLowerCase().contains(query);
                    final matchesCategory = _categoryFilter == null || service.categoryId == _categoryFilter;
                    return matchesQuery && matchesCategory;
                  }).toList();

                  if (results.isEmpty) {
                    return Center(
                      child: Text('No services match.', style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w600, color: tokens.mut)),
                    );
                  }
                  return ListView.builder(
                    padding: const EdgeInsets.fromLTRB(18, 0, 18, 18),
                    itemCount: results.length,
                    itemBuilder: (context, index) => ServiceResultTile(service: results[index]),
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

/// Shared with `CustomerServicesListScreen` — the same row style is right
/// for both a search result and a plain catalog listing.
class ServiceResultTile extends StatelessWidget {
  const ServiceResultTile({super.key, required this.service});

  final SearchableService service;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => ServiceDetailsScreen(serviceId: service.id)),
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: tokens.card,
          border: Border.all(color: tokens.line),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                service.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: tokens.tx),
              ),
            ),
            Text(
              'From ${formatRand(service.basePrice)}',
              style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w800, color: AppColors.primary),
            ),
          ],
        ),
      ),
    );
  }
}
