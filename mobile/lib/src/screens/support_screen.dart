import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../data/catalog_repository.dart';
import '../data/counties.dart';
import '../data/local_store.dart';
import '../l10n_helpers.dart';
import '../models/support_resource.dart';
import '../widgets/directory_widgets.dart';

/// Voluntary support signposting. Nothing the user does here is stored, bookmarked or sent
/// anywhere: no saved-support list exists so that a phone's contents cannot reveal help-seeking.
class SupportScreen extends StatefulWidget {
  const SupportScreen({super.key, required this.store, required this.repository});
  final LocalStore store;
  final CatalogRepository repository;

  @override
  State<SupportScreen> createState() => _SupportScreenState();
}

class _SupportScreenState extends State<SupportScreen> {
  final _search = TextEditingController();
  List<SupportResource> _items = [];
  CatalogSource _source = CatalogSource.network;
  DateTime? _fetchedAt;
  bool _loading = true;
  String? _kind;

  @override
  void initState() {
    super.initState();
    widget.store.addListener(_onStoreChanged);
    _load();
  }

  @override
  void dispose() {
    widget.store.removeListener(_onStoreChanged);
    _search.dispose();
    super.dispose();
  }

  void _onStoreChanged() {
    if (mounted) setState(() {});
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final result = await widget.repository.resources();
    if (!mounted) return;
    setState(() {
      _items = result.items;
      _source = result.source;
      _fetchedAt = result.fetchedAt;
      _loading = false;
    });
  }

  Future<void> _open(String raw) async {
    final uri = Uri.tryParse(raw);
    final opened = uri != null && isSafeExternalLink(uri) &&
        await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!opened && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(context.l10n.contactOpenFailed)));
    }
  }

  void _clearFilters() {
    _search.clear();
    widget.store.setCounty(null);
    setState(() => _kind = null);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final store = widget.store;
    final query = _search.text.toLowerCase().trim();
    final filtered = _items.where((r) {
      return countyMatches(r.county, store.county) &&
          (_kind == null || r.kind == _kind) &&
          (query.isEmpty || '${r.name} ${r.description} ${r.locationLabel}'.toLowerCase().contains(query));
    }).toList();
    final filtersActive = query.isNotEmpty || store.county != null || _kind != null;

    return RefreshIndicator(
      onRefresh: _load,
      child: ListView(padding: const EdgeInsets.all(16), children: [
        Semantics(header: true, child: Text(l10n.supportTitle, style: theme.textTheme.headlineSmall)),
        const SizedBox(height: 8),
        Text(l10n.supportIntro),
        const SizedBox(height: 12),
        // Always visible, online or offline, before any list content.
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Semantics(header: true, child: Text(l10n.supportTalkTitle, style: theme.textTheme.titleLarge)),
              const SizedBox(height: 6),
              Text(l10n.supportNacadaBody),
              const SizedBox(height: 12),
              FilledButton.icon(
                onPressed: () => _open('tel:1192'),
                icon: const Icon(Icons.call_outlined),
                label: Text(l10n.supportCall1192),
              ),
            ]),
          ),
        ),
        Card(
          color: theme.colorScheme.errorContainer,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Icon(Icons.emergency_outlined, color: theme.colorScheme.onErrorContainer),
                const SizedBox(width: 10),
                Expanded(
                  child: Semantics(
                    header: true,
                    child: Text(l10n.supportEmergencyTitle,
                        style: theme.textTheme.titleMedium?.copyWith(color: theme.colorScheme.onErrorContainer)),
                  ),
                ),
              ]),
              const SizedBox(height: 6),
              Text(l10n.supportEmergencyBody, style: TextStyle(color: theme.colorScheme.onErrorContainer)),
            ]),
          ),
        ),
        const SizedBox(height: 14),
        TextField(
          controller: _search,
          onChanged: (_) => setState(() {}),
          textInputAction: TextInputAction.search,
          decoration: InputDecoration(prefixIcon: const Icon(Icons.search), hintText: l10n.supportSearchHint),
        ),
        const SizedBox(height: 12),
        CountyDropdown(value: store.county, onChanged: store.setCounty),
        const SizedBox(height: 12),
        ChoiceChipRow(
          options: [(null, l10n.filterAll), for (final code in supportKinds) (code, kindLabel(l10n, code))],
          selected: _kind,
          onSelected: (value) => setState(() => _kind = value),
        ),
        const SizedBox(height: 12),
        CatalogStatusBanner(
          source: _source,
          fetchedAt: _fetchedAt,
          cachedMessage: l10n.statusCachedSupport,
          onRetry: _load,
        ),
        if (_loading)
          const Center(child: Padding(padding: EdgeInsets.all(24), child: CircularProgressIndicator()))
        else if (filtered.isEmpty && _items.isNotEmpty)
          MessageCard(
            message: l10n.supportNoMatches,
            action: filtersActive ? TextButton(onPressed: _clearFilters, child: Text(l10n.clearFilters)) : null,
          )
        else if (filtered.isEmpty)
          MessageCard(message: l10n.supportEmpty),
        if (!_loading)
          for (final r in filtered)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Semantics(header: true, child: Text(r.name, style: theme.textTheme.titleMedium)),
                  const SizedBox(height: 4),
                  Text([
                    kindLabel(l10n, r.kind),
                    countyLabel(l10n, r.county),
                    if (r.locationLabel.isNotEmpty) r.locationLabel,
                  ].join(' · ')),
                  const SizedBox(height: 8),
                  Text(r.description),
                  if (r.lastVerifiedAt != null) ...[
                    const SizedBox(height: 8),
                    Row(children: [
                      Icon(Icons.verified_outlined, size: 16, color: theme.colorScheme.primary),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(l10n.lastChecked(context.formatDate(r.lastVerifiedAt!)),
                            style: theme.textTheme.bodySmall),
                      ),
                    ]),
                  ],
                  const SizedBox(height: 12),
                  Wrap(spacing: 8, runSpacing: 8, children: [
                    if (r.phone.isNotEmpty)
                      OutlinedButton.icon(
                        onPressed: () => _open(safeTelUri(r.phone)),
                        icon: const Icon(Icons.call_outlined),
                        label: Text(l10n.supportCall),
                      ),
                    if (r.websiteUrl.isNotEmpty)
                      OutlinedButton.icon(
                        onPressed: () => _open(r.websiteUrl),
                        icon: const Icon(Icons.open_in_new),
                        label: Text(l10n.supportWebsite),
                      ),
                    if (r.sourceUrl.isNotEmpty)
                      TextButton(onPressed: () => _open(r.sourceUrl), child: Text(l10n.verifySource)),
                  ]),
                ]),
              ),
            ),
      ]),
    );
  }
}
