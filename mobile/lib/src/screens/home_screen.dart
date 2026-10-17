import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key, required this.onNavigate});
  final ValueChanged<int> onNavigate;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Text('Karibu HATUA', style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(height: 6),
        Text('One step forward, every day.', style: TextStyle(color: scheme.onSurfaceVariant)),
        const SizedBox(height: 24),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Icon(Icons.waving_hand_rounded, color: scheme.primary, size: 32),
              const SizedBox(height: 12),
              Text('What would help you today?', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 8),
              const Text('Explore opportunities, get confidential support information, or plan a small next step.'),
            ]),
          ),
        ),
        const SizedBox(height: 12),
        _ActionCard(
          icon: Icons.work_outline, title: 'Find opportunities',
          subtitle: 'Verified jobs, training and community programmes',
          onTap: () => onNavigate(1),
        ),
        _ActionCard(
          icon: Icons.volunteer_activism_outlined, title: 'Find support',
          subtitle: 'Trusted support resources and confidential helplines',
          onTap: () => onNavigate(2),
        ),
        _ActionCard(
          icon: Icons.flag_outlined, title: 'My next steps',
          subtitle: 'Keep track of goals privately on your device',
          onTap: () => onNavigate(3),
        ),
        const SizedBox(height: 18),
        Text('Browse freely. No account or personal history required.',
            style: TextStyle(fontSize: 13, color: scheme.onSurfaceVariant)),
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
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: onTap,
    ),
  );
}
