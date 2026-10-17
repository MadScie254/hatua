import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import 'data/catalog_repository.dart';
import 'data/local_store.dart';
import 'l10n_helpers.dart';
import 'screens/explore_screen.dart';
import 'screens/home_screen.dart';
import 'screens/plan_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/support_screen.dart';
import 'theme/app_theme.dart';

class HatuaApp extends StatefulWidget {
  /// [store] and [repository] are injectable for tests; production builds create their own.
  const HatuaApp({super.key, this.store, this.repository});
  final LocalStore? store;
  final CatalogRepository? repository;

  @override
  State<HatuaApp> createState() => _HatuaAppState();
}

class _HatuaAppState extends State<HatuaApp> {
  late final LocalStore _store = widget.store ?? LocalStore();
  late final CatalogRepository _repository = widget.repository ?? CatalogRepository();
  bool _ready = false;
  bool _failed = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    if (widget.store == null) _store.dispose();
    if (widget.repository == null) _repository.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    try {
      await _store.load();
      if (!mounted) return;
      setState(() {
        _ready = true;
        _failed = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _ready = false;
        _failed = true;
      });
    }
  }

  /// Last resort when encrypted storage cannot be read (for example a Keystore key was lost):
  /// wipe HATUA's local data so the user is not locked out of public information.
  Future<void> _resetAndLoad() async {
    try {
      await _store.clearAll();
    } catch (_) {
      // _load() below reports the failure again if storage is still unusable.
    }
    await _load();
  }

  @override
  Widget build(BuildContext context) => ListenableBuilder(
        listenable: _store,
        builder: (context, _) => MaterialApp(
          onGenerateTitle: (context) => context.l10n.appTitle,
          debugShowCheckedModeBanner: false,
          theme: AppTheme.light,
          darkTheme: AppTheme.dark,
          themeMode: ThemeMode.system,
          locale: _store.locale,
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          home: _failed
              ? _StorageErrorScreen(onRetry: _load, onReset: _resetAndLoad)
              : !_ready
                  ? const Scaffold(body: Center(child: CircularProgressIndicator()))
                  : AppShell(store: _store, repository: _repository),
        ),
      );
}

class _StorageErrorScreen extends StatelessWidget {
  const _StorageErrorScreen({required this.onRetry, required this.onReset});
  final VoidCallback onRetry;
  final VoidCallback onReset;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              const Icon(Icons.lock_outline, size: 44),
              const SizedBox(height: 16),
              Text(l10n.storageErrorMessage, textAlign: TextAlign.center),
              const SizedBox(height: 16),
              FilledButton(onPressed: onRetry, child: Text(l10n.retry)),
              const SizedBox(height: 8),
              TextButton(onPressed: onReset, child: Text(l10n.storageResetAction, textAlign: TextAlign.center)),
            ]),
          ),
        ),
      ),
    );
  }
}

/// Bottom-navigation shell. Tabs are built on first visit so the app does not download
/// directories the user never opens (data costs matter to HATUA's users).
class AppShell extends StatefulWidget {
  const AppShell({super.key, required this.store, required this.repository});
  final LocalStore store;
  final CatalogRepository repository;

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _selected = 0;
  final _visited = <int>{0};

  void _select(int index) => setState(() {
        _selected = index;
        _visited.add(index);
      });

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final pages = <Widget Function()>[
      () => HomeScreen(onNavigate: _select),
      () => ExploreScreen(store: widget.store, repository: widget.repository),
      () => SupportScreen(store: widget.store, repository: widget.repository),
      () => PlanScreen(store: widget.store),
      () => SettingsScreen(store: widget.store),
    ];
    return Scaffold(
      appBar: AppBar(title: Text(l10n.appTitle, style: const TextStyle(fontWeight: FontWeight.bold))),
      body: IndexedStack(
        index: _selected,
        children: [
          for (var i = 0; i < pages.length; i++) _visited.contains(i) ? pages[i]() : const SizedBox.shrink(),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selected,
        onDestinationSelected: _select,
        destinations: [
          NavigationDestination(
              icon: const Icon(Icons.home_outlined), selectedIcon: const Icon(Icons.home), label: l10n.navHome),
          NavigationDestination(
              icon: const Icon(Icons.work_outline), selectedIcon: const Icon(Icons.work), label: l10n.navExplore),
          NavigationDestination(
              icon: const Icon(Icons.volunteer_activism_outlined),
              selectedIcon: const Icon(Icons.volunteer_activism),
              label: l10n.navSupport),
          NavigationDestination(
              icon: const Icon(Icons.flag_outlined), selectedIcon: const Icon(Icons.flag), label: l10n.navPlan),
          NavigationDestination(
              icon: const Icon(Icons.settings_outlined),
              selectedIcon: const Icon(Icons.settings),
              label: l10n.navSettings),
        ],
      ),
    );
  }
}
