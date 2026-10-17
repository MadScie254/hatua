import 'package:flutter/material.dart';
import '../data/local_store.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key, required this.store});
  final LocalStore store;

  Future<void> _clear(BuildContext context) async {
    final approved = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete local data?'),
        content: const Text('This permanently removes goals, saved opportunities and cached public listings from this device.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogContext, false), child: const Text('Cancel')),
          FilledButton(onPressed: () => Navigator.pop(dialogContext, true), child: const Text('Delete')),
        ],
      ),
    );
    if (approved != true) return;
    try {
      await store.clearAll();
      if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Local app data cleared.')));
    } catch (_) {
      if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Could not clear all data. Please retry.')));
    }
  }

  @override
  Widget build(BuildContext context) => ListView(padding: const EdgeInsets.all(16), children: [
    Text('Settings & privacy', style: Theme.of(context).textTheme.headlineSmall),
    const SizedBox(height: 14),
    const Card(child: ListTile(
      leading: Icon(Icons.person_outline),
      title: Text('Guest mode'),
      subtitle: Text('No account required. This version does not create or upload a personal profile.'),
    )),
    const Card(child: ListTile(
      leading: Icon(Icons.shield_outlined),
      title: Text('Privacy by design'),
      subtitle: Text('Goals are stored using encrypted device storage. Public directory data may be cached. No medical history is collected.'),
    )),
    const Card(child: ListTile(
      leading: Icon(Icons.language),
      title: Text('Language'),
      subtitle: Text('English interface in this starter build. Kiswahili translation is scheduled before public release.'),
    )),
    Card(child: ListTile(
      leading: const Icon(Icons.delete_forever_outlined),
      title: const Text('Delete my local data'),
      subtitle: const Text('Remove saved listings, goals, and cached directories.'),
      onTap: () => _clear(context),
    )),
    const SizedBox(height: 18),
    const Text('HATUA v0.1.0 · Development preview'),
    const SizedBox(height: 8),
    const Text('HATUA is an information and referral tool, not a healthcare provider or a guarantee of employment.'),
  ]);
}
