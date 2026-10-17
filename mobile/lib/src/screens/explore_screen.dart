import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../data/catalog_repository.dart';
import '../data/local_store.dart';
import '../models/opportunity.dart';

class ExploreScreen extends StatefulWidget {
  const ExploreScreen({super.key, required this.store, required this.repository});
  final LocalStore store;
  final CatalogRepository repository;

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  final _search = TextEditingController();
  List<Opportunity> _items = [];
  bool _loading = true;
  bool _fromCache = false;
  bool _onlySaved = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final result = await widget.repository.opportunities();
    if (!mounted) return;
    setState(() { _items = result.items; _fromCache = result.fromCache; _loading = false; });
  }

  Future<void> _openUrl(String raw) async {
    final url = Uri.tryParse(raw);
    if (url == null || !['https', 'http'].contains(url.scheme)) return;
    if (!await launchUrl(url, mode: LaunchMode.externalApplication) && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Unable to open this link.')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final query = _search.text.trim().toLowerCase();
    final filtered = _items.where((op) {
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      return (op.deadline == null || !op.deadline!.isBefore(today)) &&
          (!_onlySaved || widget.store.isSaved(op.id)) &&
          (query.isEmpty || '${op.title} ${op.organisation} ${op.county} ${op.summary}'.toLowerCase().contains(query));
    }).toList();

    return RefreshIndicator(
      onRefresh: _load,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text('Explore opportunities', style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 6),
          const Text('Public listings are reviewed before publication. Always verify details with the original source.'),
          const SizedBox(height: 16),
          TextField(
            controller: _search,
            onChanged: (_) => setState(() {}),
            decoration: const InputDecoration(prefixIcon: Icon(Icons.search), hintText: 'Search jobs, training, counties'),
          ),
          SwitchListTile.adaptive(
            contentPadding: EdgeInsets.zero,
            title: const Text('Saved only'),
            value: _onlySaved,
            onChanged: (v) => setState(() => _onlySaved = v),
          ),
          if (_fromCache) const Card(child: ListTile(
            leading: Icon(Icons.wifi_off_outlined),
            title: Text('Offline or server unavailable'),
            subtitle: Text('Showing previously saved public listings, if available. Check deadlines again when online.'),
          )),
          if (_loading) const Center(child: Padding(
            padding: EdgeInsets.all(24), child: CircularProgressIndicator(),
          )),
          if (!_loading && filtered.isEmpty) const Card(child: Padding(
            padding: EdgeInsets.all(20),
            child: Text('No verified opportunities to show yet. Pull down to refresh when connected.'),
          )),
          for (final op in filtered)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Row(children: [
                    Expanded(child: Text(op.title, style: Theme.of(context).textTheme.titleMedium)),
                    IconButton(
                      tooltip: widget.store.isSaved(op.id) ? 'Remove bookmark' : 'Save opportunity',
                      onPressed: () async {
                        await widget.store.toggleBookmark(op.id);
                        if (mounted) setState(() {});
                      },
                      icon: Icon(widget.store.isSaved(op.id) ? Icons.bookmark : Icons.bookmark_outline),
                    ),
                  ]),
                  Text(op.organisation, style: const TextStyle(fontWeight: FontWeight.w500)),
                  const SizedBox(height: 8),
                  Text('${op.category} · ${op.county}${op.deadline != null ? ' · Due ${op.deadline!.year}-${op.deadline!.month.toString().padLeft(2, '0')}-${op.deadline!.day.toString().padLeft(2, '0')}' : ''}'),
                  if (op.costLabel.isNotEmpty) Text('Cost: ${op.costLabel}'),
                  const SizedBox(height: 8),
                  Text(op.summary, maxLines: 4, overflow: TextOverflow.ellipsis),
                  if (op.eligibility.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Text('Eligibility: ${op.eligibility}', maxLines: 4, overflow: TextOverflow.ellipsis),
                  ],
                  const SizedBox(height: 12),
                  Wrap(spacing: 8, children: [
                    if (op.applicationUrl.isNotEmpty)
                      FilledButton.icon(onPressed: () => _openUrl(op.applicationUrl),
                        icon: const Icon(Icons.open_in_new), label: const Text('Apply at source')),
                    if (op.sourceUrl.isNotEmpty)
                      OutlinedButton(onPressed: () => _openUrl(op.sourceUrl), child: const Text('Verify source')),
                  ]),
                ]),
              ),
            ),
        ],
      ),
    );
  }
}
