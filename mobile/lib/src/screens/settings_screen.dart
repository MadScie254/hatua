import 'package:flutter/material.dart';

import '../data/local_store.dart';
import '../l10n_helpers.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key, required this.store});
  final LocalStore store;

  Future<void> _clear(BuildContext context) async {
    final l10n = context.l10n;
    final messenger = ScaffoldMessenger.of(context);
    final approved = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.settingsDeleteConfirmTitle),
        content: Text(l10n.settingsDeleteConfirmBody),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogContext, false), child: Text(l10n.cancel)),
          FilledButton(onPressed: () => Navigator.pop(dialogContext, true), child: Text(l10n.delete)),
        ],
      ),
    );
    if (approved != true) return;
    try {
      await store.clearAll();
      messenger.showSnackBar(SnackBar(content: Text(l10n.settingsDeleted)));
    } catch (_) {
      messenger.showSnackBar(SnackBar(content: Text(l10n.settingsDeleteFailed)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    return ListenableBuilder(
      listenable: store,
      builder: (context, _) => ListView(padding: const EdgeInsets.all(16), children: [
        Semantics(header: true, child: Text(l10n.settingsTitle, style: theme.textTheme.headlineSmall)),
        const SizedBox(height: 14),
        Card(
          child: ListTile(
            leading: const Icon(Icons.person_outline),
            title: Text(l10n.settingsGuestTitle),
            subtitle: Text(l10n.settingsGuestBody),
          ),
        ),
        Card(
          child: ListTile(
            leading: const Icon(Icons.shield_outlined),
            title: Text(l10n.settingsPrivacyTitle),
            subtitle: Text(l10n.settingsPrivacyBody),
          ),
        ),
        Card(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              ListTile(leading: const Icon(Icons.language), title: Text(l10n.settingsLanguageTitle)),
              RadioGroup<String?>(
                groupValue: store.languageCode,
                onChanged: store.setLanguageCode,
                child: Column(children: [
                  RadioListTile<String?>(value: null, title: Text(l10n.settingsLanguageSystem)),
                  RadioListTile<String?>(value: 'en', title: Text(l10n.settingsLanguageEnglish)),
                  RadioListTile<String?>(value: 'sw', title: Text(l10n.settingsLanguageSwahili)),
                ]),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
                child: Text(l10n.settingsSwahiliDraftNote, style: theme.textTheme.bodySmall),
              ),
            ]),
          ),
        ),
        Card(
          child: ListTile(
            leading: const Icon(Icons.delete_forever_outlined),
            title: Text(l10n.settingsDeleteTitle),
            subtitle: Text(l10n.settingsDeleteBody),
            onTap: () => _clear(context),
          ),
        ),
        const SizedBox(height: 18),
        Text(l10n.settingsVersion),
        const SizedBox(height: 8),
        Text(l10n.settingsDisclaimer),
      ]),
    );
  }
}
