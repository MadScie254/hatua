import 'package:flutter/material.dart';

import '../l10n_helpers.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key, required this.onNavigate});
  final ValueChanged<int> onNavigate;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Semantics(
          header: true,
          child: Text(l10n.homeGreeting,
              style: theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold)),
        ),
        const SizedBox(height: 6),
        Text(l10n.homeTagline, style: TextStyle(color: scheme.onSurfaceVariant)),
        const SizedBox(height: 24),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              ExcludeSemantics(child: Icon(Icons.waving_hand_rounded, color: scheme.primary, size: 32)),
              const SizedBox(height: 12),
              Text(l10n.homeQuestion, style: theme.textTheme.titleLarge),
              const SizedBox(height: 8),
              Text(l10n.homeIntro),
            ]),
          ),
        ),
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
        Text(l10n.homeGuestNote, style: theme.textTheme.bodySmall?.copyWith(color: scheme.onSurfaceVariant)),
      ],
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
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          leading: Icon(icon, color: Theme.of(context).colorScheme.primary, size: 30),
          title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
          subtitle: Text(subtitle),
          trailing: const Icon(Icons.chevron_right),
          onTap: onTap,
        ),
      );
}
