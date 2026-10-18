import 'package:flutter/material.dart';

import '../data/local_store.dart';
import '../l10n_helpers.dart';
import '../widgets/directory_widgets.dart';

/// Shown once, before anything else: language, what HATUA keeps private, optional county.
/// Every choice can be skipped or changed later in Settings; nothing here leaves the device.
class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key, required this.store});
  final LocalStore store;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    return Scaffold(
      body: SafeArea(
        child: CenteredContent(
          child: ListenableBuilder(
            listenable: store,
            builder: (context, _) => ListView(padding: const EdgeInsets.fromLTRB(24, 32, 24, 24), children: [
              Text('HATUA',
                  style: theme.textTheme.titleLarge?.copyWith(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.2,
                  )),
              const SizedBox(height: 20),
              Semantics(header: true, child: Text(l10n.homeGreeting, style: theme.textTheme.headlineMedium)),
              const SizedBox(height: 4),
              Text(l10n.homeTagline, style: theme.textTheme.titleMedium),
              const SizedBox(height: 28),
              Text(l10n.welcomeLanguage, style: theme.textTheme.titleMedium),
              const SizedBox(height: 8),
              SegmentedButton<String>(
                segments: [
                  ButtonSegment(value: 'en', label: Text(l10n.settingsLanguageEnglish)),
                  ButtonSegment(value: 'sw', label: Text(l10n.settingsLanguageSwahili)),
                ],
                selected: {store.languageCode ?? Localizations.localeOf(context).languageCode},
                onSelectionChanged: (choice) => store.setLanguageCode(choice.first),
              ),
              const SizedBox(height: 28),
              Text(l10n.welcomePrivacyTitle, style: theme.textTheme.titleMedium),
              const SizedBox(height: 4),
              MetaRow(icon: Icons.person_off_outlined, text: l10n.welcomeNoAccount),
              MetaRow(icon: Icons.phone_android, text: l10n.welcomeOnDevice),
              MetaRow(icon: Icons.visibility_off_outlined, text: l10n.welcomeSupportPrivate),
              const SizedBox(height: 28),
              Text(l10n.welcomeCounty, style: theme.textTheme.titleMedium),
              const SizedBox(height: 8),
              CountyDropdown(value: store.county, onChanged: store.setCounty),
              const SizedBox(height: 32),
              FilledButton(
                style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(52)),
                onPressed: store.completeOnboarding,
                child: Text(l10n.welcomeStart),
              ),
            ]),
          ),
        ),
      ),
    );
  }
}
