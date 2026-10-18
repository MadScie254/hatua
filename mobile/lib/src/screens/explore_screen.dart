import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../data/catalog_repository.dart';
import '../data/counties.dart';
import '../data/local_store.dart';
import '../l10n_helpers.dart';
import '../models/opportunity.dart';
import '../widgets/directory_widgets.dart';
import 'opportunity_detail_screen.dart';

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

  void _openDetails(Opportunity op) {
    Navigator.of(context).push(MaterialPageRoute<void>(
      builder: (_) => OpportunityDetailScreen(
        opportunity: op,
        store: widget.store,
        repository: widget.repository,
        today: widget.clock(),
      ),
    ));
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
    }).toList()
      ..sort((a, b) {
        // Your county, then nationwide listings (open to everyone), then other counties;
        // within each, the soonest deadline first, then A-Z.
        int rank(Opportunity op) => op.county == store.county ? 0 : (op.county == nationwide ? 1 : 2);
        final byPlace = rank(a).compareTo(rank(b));
        if (byPlace != 0) return byPlace;
        final da = a.deadline, db = b.deadline;
        if (da != null || db != null) {
          if (da == null) return 1;
          if (db == null) return -1;
          final byDate = da.compareTo(db);
          if (byDate != 0) return byDate;
        }
        return a.title.toLowerCase().compareTo(b.title.toLowerCase());
      });
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
          if (filtered.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 4, bottom: 4),
              child: Text(l10n.resultsCount(filtered.length), style: Theme.of(context).textTheme.labelLarge),
            ),
          if (_loading && _items.isEmpty)
            const Center(child: Padding(padding: EdgeInsets.all(24), child: CircularProgressIndicator()))
          else if (filtered.isEmpty && open.isNotEmpty)
            MessageCard(
              message: l10n.exploreNoMatches,
              action: filtersActive ? TextButton(onPressed: _clearFilters, child: Text(l10n.clearFilters)) : null,
            )
          else if (filtered.isEmpty && _source != CatalogSource.unavailable)
            MessageCard(message: l10n.exploreEmpty),
          if (!_loading || _items.isNotEmpty)
            for (final op in filtered)
              _OpportunityCard(
                opportunity: op,
                today: today,
                saved: store.isSaved(op.id),
                tracked: store.isTracked(op.id),
                onToggleSaved: () => store.toggleBookmark(op.id),
                onDetails: () => _openDetails(op),
                onApply: op.applicationUrl.isEmpty ? null : () => _openUrl(op.applicationUrl),
              ),
        ],
      ),
    );
  }
}

class _OpportunityCard extends StatelessWidget {
  const _OpportunityCard({
    required this.opportunity,
    required this.today,
    required this.saved,
    required this.tracked,
    required this.onToggleSaved,
    required this.onDetails,
    required this.onApply,
  });

  final Opportunity opportunity;
  final DateTime today;
  final bool saved;
  final bool tracked;
  final VoidCallback onToggleSaved;
  final VoidCallback onDetails;
  final VoidCallback? onApply;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final op = opportunity;
    final theme = Theme.of(context);
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onDetails,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 14, 8, 12),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Semantics(header: true, child: Text(op.title, style: theme.textTheme.titleMedium)),
                  const SizedBox(height: 2),
                  Text(op.organisation, style: theme.textTheme.bodyMedium),
                ]),
              ),
              IconButton(
                tooltip: saved ? l10n.removeBookmark : l10n.saveOpportunity,
                onPressed: onToggleSaved,
                isSelected: saved,
                icon: const Icon(Icons.bookmark_outline),
                selectedIcon: const Icon(Icons.bookmark),
              ),
            ]),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: Wrap(spacing: 8, runSpacing: 6, children: [
                TagLabel(categoryLabel(l10n, op.category)),
                if (op.deadline != null) DeadlineBadge(deadline: op.deadline!, today: today),
                if (tracked) TagLabel(l10n.exploreTracked),
              ]),
            ),
            MetaRow(icon: Icons.place_outlined, text: countyLabel(l10n, op.county)),
            if (op.costLabel.isNotEmpty) MetaRow(icon: Icons.payments_outlined, text: op.costLabel),
            Padding(
              padding: const EdgeInsets.only(top: 8, right: 8),
              child: Text(op.summary, maxLines: 3, overflow: TextOverflow.ellipsis),
            ),
            const SizedBox(height: 10),
            Wrap(spacing: 8, runSpacing: 8, children: [
              if (onApply != null)
                FilledButton.icon(
                  onPressed: onApply,
                  icon: const Icon(Icons.open_in_new),
                  label: Text(l10n.applyAtSource),
                ),
              OutlinedButton(onPressed: onDetails, child: Text(l10n.detailsButton)),
            ]),
          ]),
        ),
      ),
    );
  }
}
