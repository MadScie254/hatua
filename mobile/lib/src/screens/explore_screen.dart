import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../data/catalog_repository.dart';
import '../data/counties.dart';
import '../data/local_store.dart';
import '../l10n_helpers.dart';
import '../models/opportunity.dart';
import '../widgets/directory_widgets.dart';

class ExploreScreen extends StatefulWidget {
  const ExploreScreen({super.key, required this.store, required this.repository, this.clock = DateTime.now});
  final LocalStore store;
  final CatalogRepository repository;
  final DateTime Function() clock;

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  final _search = TextEditingController();
  List<Opportunity> _items = [];
  CatalogSource _source = CatalogSource.network;
  DateTime? _fetchedAt;
  bool _loading = true;
  bool _onlySaved = false;
  String? _category;

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
    final result = await widget.repository.opportunities();
    if (!mounted) return;
    setState(() {
      _items = result.items;
      _source = result.source;
      _fetchedAt = result.fetchedAt;
      _loading = false;
    });
  }

  Future<void> _openUrl(String raw) async {
    final uri = Uri.tryParse(raw);
    final opened = uri != null && isSafeExternalLink(uri) && uri.scheme != 'tel' &&
        await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!opened && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(context.l10n.linkOpenFailed)));
    }
  }

  void _clearFilters() {
    _search.clear();
    widget.store.setCounty(null);
    setState(() {
      _category = null;
      _onlySaved = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final store = widget.store;
    final query = _search.text.trim().toLowerCase();
    final today = widget.clock();
    final open = _items.where((op) => op.isOpenOn(today)).toList();
    final filtered = open.where((op) {
      return countyMatches(op.county, store.county) &&
          (_category == null || op.category == _category) &&
          (!_onlySaved || store.isSaved(op.id)) &&
          (query.isEmpty ||
              '${op.title} ${op.organisation} ${op.summary}'.toLowerCase().contains(query));
    }).toList();
    final filtersActive = query.isNotEmpty || store.county != null || _category != null || _onlySaved;

    return RefreshIndicator(
      onRefresh: _load,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Semantics(
            header: true,
            child: Text(l10n.exploreTitle, style: Theme.of(context).textTheme.headlineSmall),
          ),
          const SizedBox(height: 6),
          Text(l10n.exploreIntro),
          const SizedBox(height: 16),
          TextField(
            controller: _search,
            onChanged: (_) => setState(() {}),
            textInputAction: TextInputAction.search,
            decoration: InputDecoration(prefixIcon: const Icon(Icons.search), hintText: l10n.exploreSearchHint),
          ),
          const SizedBox(height: 12),
          CountyDropdown(value: store.county, onChanged: store.setCounty),
          const SizedBox(height: 12),
          ChoiceChipRow(
            options: [
              (null, l10n.filterAll),
              for (final code in opportunityCategories) (code, categoryLabel(l10n, code)),
            ],
            selected: _category,
            onSelected: (value) => setState(() => _category = value),
          ),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(l10n.exploreSavedOnly),
            value: _onlySaved,
            onChanged: (v) => setState(() => _onlySaved = v),
          ),
          CatalogStatusBanner(
            source: _source,
            fetchedAt: _fetchedAt,
            cachedMessage: l10n.statusCachedOpportunities,
            onRetry: _load,
          ),
          if (_loading)
            const Center(child: Padding(padding: EdgeInsets.all(24), child: CircularProgressIndicator()))
          else if (filtered.isEmpty && open.isNotEmpty)
            MessageCard(
              message: l10n.exploreNoMatches,
              action: filtersActive ? TextButton(onPressed: _clearFilters, child: Text(l10n.clearFilters)) : null,
            )
          else if (filtered.isEmpty && _source != CatalogSource.unavailable)
            MessageCard(message: l10n.exploreEmpty),
          if (!_loading)
            for (final op in filtered)
              _OpportunityCard(
                opportunity: op,
                saved: store.isSaved(op.id),
                onToggleSaved: () => store.toggleBookmark(op.id),
                onOpen: _openUrl,
              ),
        ],
      ),
    );
  }
}

class _OpportunityCard extends StatelessWidget {
  const _OpportunityCard({
    required this.opportunity,
    required this.saved,
    required this.onToggleSaved,
    required this.onOpen,
  });

  final Opportunity opportunity;
  final bool saved;
  final VoidCallback onToggleSaved;
  final ValueChanged<String> onOpen;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final op = opportunity;
    final theme = Theme.of(context);
    final meta = [
      categoryLabel(l10n, op.category),
      countyLabel(l10n, op.county),
      if (op.deadline != null) l10n.opportunityCloses(context.formatDate(op.deadline!)),
    ].join(' · ');
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Expanded(
              child: Semantics(header: true, child: Text(op.title, style: theme.textTheme.titleMedium)),
            ),
            IconButton(
              tooltip: saved ? l10n.removeBookmark : l10n.saveOpportunity,
              onPressed: onToggleSaved,
              isSelected: saved,
              icon: const Icon(Icons.bookmark_outline),
              selectedIcon: const Icon(Icons.bookmark),
            ),
          ]),
          Text(op.organisation, style: const TextStyle(fontWeight: FontWeight.w500)),
          const SizedBox(height: 8),
          Text(meta),
          if (op.costLabel.isNotEmpty) Text(l10n.opportunityCost(op.costLabel)),
          const SizedBox(height: 8),
          Text(op.summary, maxLines: 4, overflow: TextOverflow.ellipsis),
          if (op.eligibility.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(l10n.opportunityEligibility(op.eligibility), maxLines: 4, overflow: TextOverflow.ellipsis),
          ],
          if (op.lastVerifiedAt != null) ...[
            const SizedBox(height: 8),
            Row(children: [
              Icon(Icons.verified_outlined, size: 16, color: theme.colorScheme.primary),
              const SizedBox(width: 6),
              Expanded(
                child: Text(l10n.lastChecked(context.formatDate(op.lastVerifiedAt!)),
                    style: theme.textTheme.bodySmall),
              ),
            ]),
          ],
          const SizedBox(height: 12),
          Wrap(spacing: 8, runSpacing: 8, children: [
            if (op.applicationUrl.isNotEmpty)
              FilledButton.icon(
                onPressed: () => onOpen(op.applicationUrl),
                icon: const Icon(Icons.open_in_new),
                label: Text(l10n.applyAtSource),
              ),
            if (op.sourceUrl.isNotEmpty)
              OutlinedButton(onPressed: () => onOpen(op.sourceUrl), child: Text(l10n.verifySource)),
          ]),
        ]),
      ),
    );
  }
}
