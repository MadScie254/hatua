import 'package:flutter/material.dart';

import '../data/counties.dart';
import '../data/local_store.dart';
import '../l10n_helpers.dart';
import '../theme/app_theme.dart';
import '../widgets/directory_widgets.dart';
import 'support_screen.dart' show openSupportLink;

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key, required this.onNavigate, this.store});
  final ValueChanged<int> onNavigate;

  /// For the county shortcut; optional so the screen can be shown on its own.
  final LocalStore? store;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final store = this.store;
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
      children: [
        Semantics(header: true, child: Text(l10n.homeGreeting, style: theme.textTheme.headlineMedium)),
        const SizedBox(height: 4),
        Text(l10n.homeTagline, style: theme.textTheme.titleMedium?.copyWith(color: scheme.onSurfaceVariant)),
        const SizedBox(height: 20),
        const _TalkNowBand(),
        if (store != null) ...[
          const SizedBox(height: 16),
          ListenableBuilder(listenable: store, builder: (context, _) => _CountyShortcut(store: store)),
        ],
        const SizedBox(height: 20),
        Semantics(header: true, child: Text(l10n.homeQuestion, style: theme.textTheme.titleLarge)),
        const SizedBox(height: 4),
        Text(l10n.homeIntro, style: TextStyle(color: scheme.onSurfaceVariant)),
        const SizedBox(height: 12),
        _ActionCard(
          icon: Icons.work_outline,
          title: l10n.homeFindOpportunities,
          subtitle: l10n.homeFindOpportunitiesSubtitle,
          onTap: () => onNavigate(1),
        ),
        _ActionCard(
          icon: Icons.volunteer_activism_outlined,
          title: l10n.homeFindSupport,
          subtitle: l10n.homeFindSupportSubtitle,
          onTap: () => onNavigate(2),
        ),
        _ActionCard(
          icon: Icons.flag_outlined,
          title: l10n.homeNextSteps,
          subtitle: l10n.homeNextStepsSubtitle,
          onTap: () => onNavigate(3),
        ),
        const SizedBox(height: 18),
        MetaRow(icon: Icons.lock_outline, text: l10n.homeGuestNote),
      ],
    );
  }
}

/// The one bold element in the app: a person to talk to, one tap away, before anything else.
class _TalkNowBand extends StatelessWidget {
  const _TalkNowBand();

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final colors = HatuaColors.of(context);
    return Material(
      color: colors.band,
      borderRadius: BorderRadius.circular(24),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 18),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Semantics(
            header: true,
            child: Text(l10n.homeTalkNowTitle, style: theme.textTheme.titleLarge?.copyWith(color: colors.onBand)),
          ),
          const SizedBox(height: 6),
          Text(l10n.homeTalkNowBody, style: theme.textTheme.bodyMedium?.copyWith(color: colors.onBand)),
          const SizedBox(height: 16),
          FilledButton.icon(
            style: FilledButton.styleFrom(
              backgroundColor: colors.onBand,
              foregroundColor: colors.band,
              minimumSize: const Size.fromHeight(52),
              textStyle: theme.textTheme.titleMedium,
            ),
            onPressed: () => openSupportLink(context, 'tel:1192'),
            icon: const Icon(Icons.call),
            label: Text(l10n.homeCall1192),
          ),
        ]),
      ),
    );
  }
}

class _CountyShortcut extends StatelessWidget {
  const _CountyShortcut({required this.store});
  final LocalStore store;

  Future<void> _pick(BuildContext context) async {
    final l10n = context.l10n;
    final chosen = await showModalBottomSheet<String>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (sheetContext) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.7,
        builder: (context, controller) => ListView(controller: controller, children: [
          ListTile(
            title: Text(l10n.filterAllCounties),
            onTap: () => Navigator.pop(sheetContext, ''),
          ),
          for (final county in kenyanCounties)
            ListTile(
              title: Text(county),
              selected: county == store.county,
              onTap: () => Navigator.pop(sheetContext, county),
            ),
        ]),
      ),
    );
    if (chosen != null) await store.setCounty(chosen.isEmpty ? null : chosen);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final county = store.county;
    return Card(
      child: ListTile(
        leading: Icon(Icons.place_outlined, color: Theme.of(context).colorScheme.primary),
        title: Text(county == null ? l10n.homeCountyChoose : l10n.homeCountySelected(county)),
        trailing: county == null
            ? const Icon(Icons.chevron_right)
            : Text(l10n.changeCounty, style: TextStyle(color: Theme.of(context).colorScheme.primary)),
        onTap: () => _pick(context),
      ),
    );
  }
}

class _ActionCard extends StatelessWidget {
  const _ActionCard({required this.icon, required this.title, required this.subtitle, required this.onTap});
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Card(
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          leading: Icon(icon, color: Theme.of(context).colorScheme.primary, size: 28),
          title: Text(title, style: Theme.of(context).textTheme.titleMedium),
          subtitle: Text(subtitle),
          trailing: const Icon(Icons.chevron_right),
          onTap: onTap,
        ),
      );
}
