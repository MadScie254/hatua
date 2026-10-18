import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../data/catalog_repository.dart';
import '../data/local_store.dart';
import '../l10n_helpers.dart';
import '../models/opportunity.dart';
import '../widgets/directory_widgets.dart';

/// Everything about one opportunity, with the action (apply) at the bottom where a thumb is.
class OpportunityDetailScreen extends StatelessWidget {
  const OpportunityDetailScreen({
    super.key,
    required this.opportunity,
    required this.store,
    required this.repository,
    required this.today,
  });

  final Opportunity opportunity;
  final LocalStore store;
  final CatalogRepository repository;
  final DateTime today;

  Future<void> _open(BuildContext context, String raw) async {
    final uri = Uri.tryParse(raw);
    final opened = uri != null && isSafeExternalLink(uri) && uri.scheme != 'tel' &&
        await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!opened && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(context.l10n.linkOpenFailed)));
    }
  }

  Future<void> _track(BuildContext context) async {
    final l10n = context.l10n;
    final messenger = ScaffoldMessenger.of(context);
    try {
      await store.trackOpportunity(opportunity);
      messenger.showSnackBar(SnackBar(content: Text(l10n.exploreTrackAdded)));
    } catch (_) {
      messenger.showSnackBar(SnackBar(content: Text(l10n.planSaveFailed)));
    }
  }

  String _shareText(BuildContext context) {
    final op = opportunity;
    final link = op.applicationUrl.isNotEmpty ? op.applicationUrl : op.sourceUrl;
    return [op.title, op.organisation, if (link.isNotEmpty) link].join('\n');
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final op = opportunity;
    return ListenableBuilder(
      listenable: store,
      builder: (context, _) {
        final saved = store.isSaved(op.id);
        // Tracking needs the Android vault; on the web the option is simply not offered.
        final canTrack = store.goalsStatus == GoalsStatus.ready;
        return Scaffold(
          appBar: AppBar(
            title: Text(categoryLabel(l10n, op.category)),
            actions: [
              IconButton(
                tooltip: saved ? l10n.removeBookmark : l10n.saveOpportunity,
                onPressed: () => store.toggleBookmark(op.id),
                isSelected: saved,
                icon: const Icon(Icons.bookmark_outline),
                selectedIcon: const Icon(Icons.bookmark),
              ),
            ],
          ),
          body: CenteredContent(
            child: ListView(padding: const EdgeInsets.fromLTRB(20, 4, 20, 24), children: [
              Semantics(header: true, child: Text(op.title, style: theme.textTheme.headlineSmall)),
              const SizedBox(height: 6),
              Text(op.organisation, style: theme.textTheme.titleMedium),
              const SizedBox(height: 12),
              Wrap(spacing: 8, runSpacing: 8, children: [
                TagLabel(countyLabel(l10n, op.county)),
                if (op.deadline != null)
                  DeadlineBadge(deadline: op.deadline!, today: today)
                else
                  TagLabel(l10n.deadlineNone),
              ]),
              if (op.costLabel.isNotEmpty) ...[
                const SizedBox(height: 18),
                Text(l10n.detailCost, style: theme.textTheme.titleMedium),
                const SizedBox(height: 4),
                Text(op.costLabel),
              ],
              const SizedBox(height: 18),
              Text(l10n.detailAbout, style: theme.textTheme.titleMedium),
              const SizedBox(height: 4),
              SelectableText(op.summary),
              if (op.eligibility.isNotEmpty) ...[
                const SizedBox(height: 18),
                Text(l10n.detailWhoCanApply, style: theme.textTheme.titleMedium),
                const SizedBox(height: 4),
                SelectableText(op.eligibility),
              ],
              const SizedBox(height: 18),
              Text(l10n.detailHowToApply, style: theme.textTheme.titleMedium),
              const SizedBox(height: 8),
              if (op.applicationUrl.isNotEmpty)
                FilledButton.icon(
                  onPressed: () => _open(context, op.applicationUrl),
                  icon: const Icon(Icons.open_in_new),
                  label: Text(l10n.applyAtSource),
                )
              else
                Text(l10n.detailNoApplyLink),
              const SizedBox(height: 8),
              Wrap(spacing: 8, runSpacing: 8, children: [
                if (op.sourceUrl.isNotEmpty)
                  OutlinedButton(onPressed: () => _open(context, op.sourceUrl), child: Text(l10n.verifySource)),
                if (store.isTracked(op.id))
                  Chip(avatar: const Icon(Icons.check, size: 18), label: Text(l10n.exploreTracked))
                else if (canTrack)
                  OutlinedButton.icon(
                    onPressed: () => _track(context),
                    icon: const Icon(Icons.playlist_add_check),
                    label: Text(l10n.exploreTrack),
                  ),
                OutlinedButton.icon(
                  onPressed: () => copyWithMessage(context, _shareText(context), l10n.copiedToShare),
                  icon: const Icon(Icons.copy_outlined),
                  label: Text(l10n.copyToShare),
                ),
              ]),
              const SizedBox(height: 20),
              if (op.lastVerifiedAt != null)
                MetaRow(
                  icon: Icons.verified_outlined,
                  text: l10n.lastChecked(context.formatDate(op.lastVerifiedAt!)),
                  color: theme.colorScheme.primary,
                ),
              Align(
                alignment: AlignmentDirectional.centerStart,
                child: TextButton.icon(
                  onPressed: () => showReportSheet(
                    context,
                    repository: repository,
                    target: ReportTarget.opportunity,
                    recordId: op.id,
                  ),
                  icon: const Icon(Icons.flag_outlined),
                  label: Text(l10n.reportProblem),
                ),
              ),
            ]),
          ),
        );
      },
    );
  }
}
