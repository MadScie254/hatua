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
///
/// Order of the page follows urgency: 1192 and emergency guidance (always, even offline), then
/// helplines, then treatment and support in the chosen county, then nationwide information.
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

  Future<void> _open(String raw) => openSupportLink(context, raw);

  void _clearFilters() {
    _search.clear();
    widget.store.setCounty(null);
    setState(() => _kind = null);
  }

  void _details(SupportResource r) =>
      showSupportResourceSheet(context, resource: r, repository: widget.repository);

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final store = widget.store;
    final county = store.county;
    final query = _search.text.toLowerCase().trim();
    bool matchesText(SupportResource r) =>
        (_kind == null || r.kind == _kind) &&
        (query.isEmpty || '${r.name} ${r.description} ${r.locationLabel} ${r.county}'.toLowerCase().contains(query));
    final candidates = _items.where(matchesText).toList()
      ..sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));

    final helplines = candidates.where((r) => r.kind == 'helpline' && countyMatches(r.county, county)).toList()
      ..sort((a, b) => (a.county == nationwide ? 0 : 1).compareTo(b.county == nationwide ? 0 : 1));
    final nationwideInfo = candidates.where((r) => r.kind != 'helpline' && r.county == nationwide).toList();
    final local = candidates.where((r) => r.kind != 'helpline' && r.county != nationwide).toList();
    final inCounty = county == null ? <SupportResource>[] : local.where((r) => r.county == county).toList();
    // With no county chosen, or none listed in it, show the other counties grouped by name.
    final showOtherCounties = county == null || inCounty.isEmpty;
    final byCounty = <String, List<SupportResource>>{};
    if (showOtherCounties) {
      for (final r in local) {
        byCounty.putIfAbsent(r.county, () => []).add(r);
      }
    }
    final countyNames = byCounty.keys.toList()..sort();
    final shown = helplines.length + nationwideInfo.length + inCounty.length + (showOtherCounties ? local.length : 0);
    final filtersActive = query.isNotEmpty || county != null || _kind != null;

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
        CountyDropdown(value: county, onChanged: store.setCounty),
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
        if (_loading && _items.isEmpty)
          const Center(child: Padding(padding: EdgeInsets.all(24), child: CircularProgressIndicator()))
        else if (shown == 0 && _items.isNotEmpty)
          MessageCard(
            message: l10n.supportNoMatches,
            action: filtersActive ? TextButton(onPressed: _clearFilters, child: Text(l10n.clearFilters)) : null,
          )
        else if (_items.isEmpty && _source != CatalogSource.unavailable)
          MessageCard(message: l10n.supportEmpty),
        if (helplines.isNotEmpty) ...[
          SectionHeading(l10n.supportHelplinesTitle),
          _ResourceGroup(items: helplines, onTap: _details, onCall: _open),
        ],
        if (local.isNotEmpty || county != null) ...[
          SectionHeading(l10n.supportNearTitle),
          if (county == null)
            MetaRow(icon: Icons.place_outlined, text: l10n.supportNearChooseCounty)
          else if (inCounty.isEmpty && _items.isNotEmpty)
            MetaRow(icon: Icons.info_outline, text: l10n.supportNoneInCounty(county))
          else
            _ResourceGroup(items: inCounty, onTap: _details, onCall: _open),
          if (showOtherCounties)
            for (final name in countyNames) ...[
              Padding(
                padding: const EdgeInsets.only(top: 14, bottom: 4),
                child: Semantics(
                  header: true,
                  child: Text(name, style: theme.textTheme.titleMedium?.copyWith(color: theme.colorScheme.primary)),
                ),
              ),
              _ResourceGroup(items: byCounty[name]!, onTap: _details, onCall: _open),
            ],
        ],
        if (nationwideInfo.isNotEmpty) ...[
          SectionHeading(l10n.supportMoreHelp),
          _ResourceGroup(items: nationwideInfo, onTap: _details, onCall: _open),
        ],
      ]),
    );
  }
}

Future<void> openSupportLink(BuildContext context, String raw) async {
  final uri = Uri.tryParse(raw);
  final opened = uri != null && isSafeExternalLink(uri) && await launchUrl(uri, mode: LaunchMode.externalApplication);
  if (!opened && context.mounted) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(context.l10n.contactOpenFailed)));
  }
}

/// A list of resources in one rounded block, divided into rows: denser than a card per item,
/// so a county's centres can be scanned at a glance.
class _ResourceGroup extends StatelessWidget {
  const _ResourceGroup({required this.items, required this.onTap, required this.onCall});
  final List<SupportResource> items;
  final ValueChanged<SupportResource> onTap;
  final ValueChanged<String> onCall;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    return Card(
      clipBehavior: Clip.antiAlias,
      child: Column(children: [
        for (var i = 0; i < items.length; i++) ...[
          if (i > 0) const Divider(height: 1, indent: 16),
          InkWell(
            onTap: () => onTap(items[i]),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 8, 12),
              child: Row(children: [
                Expanded(
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(items[i].name, style: theme.textTheme.titleMedium),
                    if (items[i].locationLabel.isNotEmpty)
                      MetaRow(icon: Icons.place_outlined, text: items[i].locationLabel)
                    else
                      MetaRow(icon: Icons.label_outline, text: kindLabel(l10n, items[i].kind)),
                  ]),
                ),
                if (items[i].phone.isNotEmpty)
                  IconButton.filledTonal(
                    tooltip: '${l10n.supportCall} ${items[i].name}',
                    onPressed: () => onCall(safeTelUri(items[i].phone)),
                    icon: const Icon(Icons.call_outlined),
                  )
                else
                  const Padding(padding: EdgeInsets.all(12), child: Icon(Icons.chevron_right)),
              ]),
            ),
          ),
        ],
      ]),
    );
  }
}

/// Details of one support resource. Not bookmarkable by design (see SupportScreen).
Future<void> showSupportResourceSheet(
  BuildContext context, {
  required SupportResource resource,
  required CatalogRepository repository,
}) =>
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (sheetContext) => _SupportResourceSheet(resource: resource, repository: repository),
    );

class _SupportResourceSheet extends StatelessWidget {
  const _SupportResourceSheet({required this.resource, required this.repository});
  final SupportResource resource;
  final CatalogRepository repository;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final r = resource;
    final place = [if (r.locationLabel.isNotEmpty) r.locationLabel, countyLabel(l10n, r.county)].join(', ');
    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.75,
      maxChildSize: 0.95,
      builder: (context, controller) => ListView(
        controller: controller,
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
        children: [
          Semantics(header: true, child: Text(r.name, style: theme.textTheme.headlineSmall)),
          const SizedBox(height: 10),
          Wrap(spacing: 8, runSpacing: 8, children: [TagLabel(kindLabel(l10n, r.kind))]),
          MetaRow(icon: Icons.place_outlined, text: place),
          if (r.phone.isNotEmpty) MetaRow(icon: Icons.call_outlined, text: r.phone),
          const SizedBox(height: 14),
          SelectableText(r.description),
          if (r.kind == 'facility') ...[
            const SizedBox(height: 10),
            Text(l10n.supportCallBefore, style: theme.textTheme.bodyMedium),
          ],
          const SizedBox(height: 18),
          if (r.phone.isNotEmpty)
            FilledButton.icon(
              onPressed: () => openSupportLink(context, safeTelUri(r.phone)),
              icon: const Icon(Icons.call),
              label: Text('${l10n.supportCall} ${r.phone}'),
            ),
          const SizedBox(height: 8),
          Wrap(spacing: 8, runSpacing: 8, children: [
            if (r.phone.isNotEmpty)
              OutlinedButton.icon(
                onPressed: () => copyWithMessage(context, r.phone, l10n.numberCopied),
                icon: const Icon(Icons.copy_outlined),
                label: Text(l10n.supportCopyNumber),
              ),
            if (r.locationLabel.isNotEmpty && r.kind == 'facility')
              OutlinedButton.icon(
                onPressed: () => openSupportLink(context, mapsSearchUrl(r.name, r.locationLabel, r.county)),
                icon: const Icon(Icons.directions_outlined),
                label: Text(l10n.supportDirections),
              ),
            if (r.websiteUrl.isNotEmpty)
              OutlinedButton.icon(
                onPressed: () => openSupportLink(context, r.websiteUrl),
                icon: const Icon(Icons.open_in_new),
                label: Text(l10n.supportWebsite),
              ),
            if (r.sourceUrl.isNotEmpty && r.sourceUrl != r.websiteUrl)
              OutlinedButton(onPressed: () => openSupportLink(context, r.sourceUrl), child: Text(l10n.verifySource)),
          ]),
          const SizedBox(height: 18),
          if (r.lastVerifiedAt != null)
            MetaRow(
              icon: Icons.verified_outlined,
              text: l10n.lastChecked(context.formatDate(r.lastVerifiedAt!)),
              color: theme.colorScheme.primary,
            ),
          Align(
            alignment: AlignmentDirectional.centerStart,
            child: TextButton.icon(
              onPressed: () => showReportSheet(
                context,
                repository: repository,
                target: ReportTarget.supportResource,
                recordId: r.id,
              ),
              icon: const Icon(Icons.flag_outlined),
              label: Text(l10n.reportProblem),
            ),
          ),
        ],
      ),
    );
  }
}
