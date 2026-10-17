import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../data/catalog_repository.dart';
import '../models/support_resource.dart';

class SupportScreen extends StatefulWidget {
  const SupportScreen({super.key});
  @override
  State<SupportScreen> createState() => _SupportScreenState();
}

class _SupportScreenState extends State<SupportScreen> {
  final _repo = const CatalogRepository();
  final _search = TextEditingController();
  List<SupportResource> _items = [];
  bool _loading = true;
  bool _fromCache = false;

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
    final result = await _repo.resources();
    if (!mounted) return;
    setState(() { _items = result.items; _fromCache = result.fromCache; _loading = false; });
  }

  Future<void> _open(String raw) async {
    final uri = Uri.tryParse(raw);
    if (uri == null || !['tel', 'https', 'http'].contains(uri.scheme)) return;
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication) && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Unable to open this contact.')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final query = _search.text.toLowerCase().trim();
    final filtered = _items.where((r) =>
        query.isEmpty || '${r.name} ${r.description} ${r.county}'.toLowerCase().contains(query)).toList();
    return RefreshIndicator(
      onRefresh: _load,
      child: ListView(padding: const EdgeInsets.all(16), children: [
        Text('Find support', style: Theme.of(context).textTheme.headlineSmall),
        const SizedBox(height: 8),
        const Text('Seeking help is a personal choice. Browse without signing in or sharing your history.'),
        const SizedBox(height: 12),
        Card(child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Talk to someone', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 6),
            const Text('NACADA offers alcohol and substance-use support in Kenya via 1192. Not an emergency ambulance service.'),
            const SizedBox(height: 12),
            FilledButton.icon(
              onPressed: () => _open('tel:1192'),
              icon: const Icon(Icons.call_outlined), label: const Text('Open dialer: 1192'),
            ),
          ]),
        )),
        const SizedBox(height: 14),
        TextField(
          controller: _search, onChanged: (_) => setState(() {}),
          decoration: const InputDecoration(prefixIcon: Icon(Icons.search), hintText: 'Search resources or counties'),
        ),
        const SizedBox(height: 12),
        if (_fromCache) const Card(child: ListTile(
          leading: Icon(Icons.wifi_off_outlined),
          title: Text('Using saved information'),
          subtitle: Text('Contacts and opening hours may have changed. Recheck when connected.'),
        )),
        if (_loading) const Center(child: Padding(
          padding: EdgeInsets.all(24), child: CircularProgressIndicator(),
        )),
        if (!_loading && filtered.isEmpty) const Card(child: Padding(
          padding: EdgeInsets.all(20),
          child: Text('No additional verified resources available yet. You can still use the 1192 contact above.'),
        )),
        for (final r in filtered)
          Card(child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(r.name, style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 4),
              Text('${r.kind} · ${r.county}${r.locationLabel.isNotEmpty ? ' · ${r.locationLabel}' : ''}'),
              const SizedBox(height: 8),
              Text(r.description),
              const SizedBox(height: 12),
              Wrap(spacing: 8, children: [
                if (r.phone.isNotEmpty) OutlinedButton.icon(
                  onPressed: () => _open('tel:${r.phone}'),
                  icon: const Icon(Icons.call_outlined), label: const Text('Call')),
                if (r.websiteUrl.isNotEmpty) OutlinedButton.icon(
                  onPressed: () => _open(r.websiteUrl),
                  icon: const Icon(Icons.open_in_new), label: const Text('Website')),
                if (r.sourceUrl.isNotEmpty) TextButton(
                  onPressed: () => _open(r.sourceUrl), child: const Text('Verify source')),
              ]),
            ]),
          )),
        const SizedBox(height: 16),
        const Text('If someone is unconscious, having seizures, struggling to breathe, or experiencing severe withdrawal, seek emergency medical care immediately. This app does not diagnose or treat conditions.'),
      ]),
    );
  }
}
