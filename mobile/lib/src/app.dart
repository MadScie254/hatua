import 'package:flutter/material.dart';

import 'data/local_store.dart';
import 'screens/explore_screen.dart';
import 'screens/home_screen.dart';
import 'screens/plan_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/support_screen.dart';
import 'theme/app_theme.dart';

class HatuaApp extends StatelessWidget {
  const HatuaApp({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
        title: 'HATUA',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        darkTheme: AppTheme.dark,
        themeMode: ThemeMode.system,
        home: const _Bootstrap(),
      );
}

class _Bootstrap extends StatefulWidget {
  const _Bootstrap();
  @override
  State<_Bootstrap> createState() => _BootstrapState();
}

class _BootstrapState extends State<_Bootstrap> {
  final _store = LocalStore();
  bool _ready = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      await _store.load();
      if (mounted) setState(() { _ready = true; _error = null; });
    } catch (_) {
      if (mounted) setState(() => _error = 'Secure local storage could not be opened. Please retry.');
    }
  }

  @override
  void dispose() {
    _store.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_error != null) return Scaffold(body: SafeArea(child: Center(
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        const Icon(Icons.lock_outline, size: 44),
        Padding(padding: const EdgeInsets.all(20), child: Text(_error!, textAlign: TextAlign.center)),
        FilledButton(onPressed: _load, child: const Text('Retry')),
      ]),
    )));
    if (!_ready) return const Scaffold(body: Center(child: CircularProgressIndicator()));
    return _AppShell(store: _store);
  }
}

class _AppShell extends StatefulWidget {
  const _AppShell({required this.store});
  final LocalStore store;

  @override
  State<_AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<_AppShell> {
  int _selected = 0;

  @override
  Widget build(BuildContext context) {
    final pages = [
      HomeScreen(onNavigate: (i) => setState(() => _selected = i)),
      ExploreScreen(store: widget.store),
      const SupportScreen(),
      PlanScreen(store: widget.store),
      SettingsScreen(store: widget.store),
    ];
    return Scaffold(
      appBar: AppBar(
        title: const Text('HATUA', style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            tooltip: 'Settings and privacy',
            onPressed: () => setState(() => _selected = 4),
            icon: const Icon(Icons.settings_outlined),
          ),
        ],
      ),
      body: IndexedStack(index: _selected, children: pages),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selected,
        onDestinationSelected: (i) => setState(() => _selected = i),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home), label: 'Home'),
          NavigationDestination(icon: Icon(Icons.work_outline), selectedIcon: Icon(Icons.work), label: 'Explore'),
          NavigationDestination(icon: Icon(Icons.volunteer_activism_outlined), selectedIcon: Icon(Icons.volunteer_activism), label: 'Support'),
          NavigationDestination(icon: Icon(Icons.flag_outlined), selectedIcon: Icon(Icons.flag), label: 'My Plan'),
          NavigationDestination(icon: Icon(Icons.settings_outlined), selectedIcon: Icon(Icons.settings), label: 'Settings'),
        ],
      ),
    );
  }
}
