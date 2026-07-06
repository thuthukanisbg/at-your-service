import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../core/theme/app_tokens.dart';
import 'admin_catalog_service.dart';
import 'admin_desktop_mock_data.dart';
import 'admin_status_badge.dart';

/// Category cards are real — `serviceCategories`/`services`, the same
/// collections the customer app uses (see admin_catalog_service.dart for
/// exactly what's real vs. derived: base price/avg. duration are averaged
/// from real `services` docs, not stored per-category).
///
/// The discounts table stays mock: no discount/promo/coupon data exists
/// anywhere in this app's real data (confirmed by grepping the whole
/// codebase) — see admin_desktop_mock_data.dart. "Edit pricing"/"New
/// discount"/"Add category" are visual-only, same as the design handoff's
/// own README flags them.
class AdminDesktopCatalog extends StatefulWidget {
  const AdminDesktopCatalog({super.key});

  @override
  State<AdminDesktopCatalog> createState() => _AdminDesktopCatalogState();
}

class _AdminDesktopCatalogState extends State<AdminDesktopCatalog> {
  late final Future<List<AdminCatalogCategory>> _catalogFuture = fetchCatalog();

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(32, 28, 32, 32),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1400),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Service Catalog', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, letterSpacing: -0.4, color: tokens.tx)),
                        const SizedBox(height: 3),
                        FutureBuilder<List<AdminCatalogCategory>>(
                          future: _catalogFuture,
                          builder: (context, snapshot) => Text(
                            snapshot.hasData ? '${snapshot.data!.length} service categories' : 'Every category customers can book.',
                            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: tokens.mut),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Row(
                    children: [
                      OutlinedButton.icon(onPressed: null, icon: const Icon(LucideIcons.percent, size: 14), label: const Text('New discount')),
                      const SizedBox(width: 10),
                      ElevatedButton.icon(onPressed: null, icon: const Icon(LucideIcons.plus, size: 14), label: const Text('Add category')),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 20),
              FutureBuilder<List<AdminCatalogCategory>>(
                future: _catalogFuture,
                builder: (context, snapshot) {
                  if (!snapshot.hasData && !snapshot.hasError) {
                    return const Padding(
                      padding: EdgeInsets.symmetric(vertical: 48),
                      child: Center(child: CircularProgressIndicator(strokeWidth: 2.4)),
                    );
                  }
                  if (snapshot.hasError) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 48),
                      child: Center(
                        child: Text("Couldn't load the service catalog.", style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w600, color: tokens.mut)),
                      ),
                    );
                  }
                  final categories = snapshot.data!;
                  if (categories.isEmpty) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 48),
                      child: Center(
                        child: Text('No service categories yet.', style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w600, color: tokens.mut)),
                      ),
                    );
                  }
                  return GridView.count(
                    crossAxisCount: 3,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    mainAxisSpacing: 14,
                    crossAxisSpacing: 14,
                    childAspectRatio: 1.5,
                    children: [for (final c in categories) _CatalogCard(category: c)],
                  );
                },
              ),
              const SizedBox(height: 14),
              Container(
                decoration: BoxDecoration(color: tokens.card, border: Border.all(color: tokens.line), borderRadius: BorderRadius.circular(16)),
                clipBehavior: Clip.antiAlias,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                      decoration: BoxDecoration(border: Border(bottom: BorderSide(color: tokens.line))),
                      child: Text('Active discounts', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: tokens.tx)),
                    ),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: DataTable(
                        headingRowColor: WidgetStateProperty.all(tokens.elev),
                        columns: const [
                          DataColumn(label: Text('Code')),
                          DataColumn(label: Text('Discount')),
                          DataColumn(label: Text('Category')),
                          DataColumn(label: Text('Expires')),
                          DataColumn(label: Text('Uses'), numeric: true),
                          DataColumn(label: Text('Status')),
                        ],
                        rows: [
                          for (final d in mockDiscounts)
                            DataRow(cells: [
                              DataCell(Text(d.code, style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w800, color: tokens.tx, letterSpacing: 0.2))),
                              DataCell(Text(d.discount, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: tokens.tx))),
                              DataCell(Text(d.category, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: tokens.mut))),
                              DataCell(Text(d.expires, style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, color: tokens.mut))),
                              DataCell(Text('${d.uses}', style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700, color: tokens.tx))),
                              DataCell(StatusBadge(status: d.status)),
                            ]),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CatalogCard extends StatelessWidget {
  const _CatalogCard({required this.category});
  final AdminCatalogCategory category;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(color: tokens.card, border: Border.all(color: tokens.line), borderRadius: BorderRadius.circular(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(color: category.bg, borderRadius: BorderRadius.circular(10)),
                alignment: Alignment.center,
                child: Icon(category.icon, size: 17, color: category.color),
              ),
              StatusBadge(status: category.active ? 'Active' : 'Paused'),
            ],
          ),
          const SizedBox(height: 10),
          Text(category.name, style: TextStyle(fontSize: 15.5, fontWeight: FontWeight.w800, color: tokens.tx)),
          const Spacer(),
          _KvRow(label: 'Base price', value: category.priceLabel, tokens: tokens),
          _KvRow(label: 'Avg. duration', value: category.durationLabel, tokens: tokens),
          _KvRow(label: 'Active providers', value: '${category.activeProviders}', tokens: tokens),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            height: 34,
            child: OutlinedButton(onPressed: null, child: const Text('Edit pricing')),
          ),
        ],
      ),
    );
  }
}

class _KvRow extends StatelessWidget {
  const _KvRow({required this.label, required this.value, required this.tokens});
  final String label;
  final String value;
  final AppTokens tokens;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 7),
      decoration: BoxDecoration(border: Border(top: BorderSide(color: tokens.line))),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, color: tokens.mut)),
          Text(value, style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700, color: tokens.tx)),
        ],
      ),
    );
  }
}
