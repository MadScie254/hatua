// Developer tool, not part of CI: renders real-font screenshots of key screens so a human
// (or assistant) can review layout, copy and large-text behaviour without a device.
//
//   flutter test tool/screenshots/screenshots_test.dart --dart-define=SHOTS_DIR=/abs/output/dir
//
// Uses the Roboto and Material Icons fonts shipped inside the Flutter SDK cache. Listings are
// FAKE test fixtures (test/helpers.dart), not real services.
// ignore_for_file: invalid_use_of_visible_for_testing_member

import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hatua_app/src/app.dart';
import 'package:hatua_app/src/data/local_store.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../test/helpers.dart';

const _outDir = String.fromEnvironment('SHOTS_DIR', defaultValue: 'build/screenshots');

Future<void> _loadFonts() async {
  final flutterRoot = Platform.environment['FLUTTER_ROOT'] ??
      File(Platform.resolvedExecutable).parent.parent.parent.parent.parent.parent.path;
  final fonts = '$flutterRoot/bin/cache/artifacts/material_fonts';
  final roboto = FontLoader('Roboto');
  for (final weight in ['Regular', 'Medium', 'Bold']) {
    roboto.addFont(File('$fonts/Roboto-$weight.ttf').readAsBytes().then(ByteData.sublistView));
  }
  await roboto.load();
  final icons = FontLoader('MaterialIcons')
    ..addFont(File('$fonts/MaterialIcons-Regular.otf').readAsBytes().then(ByteData.sublistView));
  await icons.load();
}

Future<void> _shoot(WidgetTester tester, String name) async {
  await tester.pumpAndSettle();
  await tester.runAsync(() async {
    final boundary = tester.renderObject<RenderRepaintBoundary>(find.byKey(const ValueKey('shot')));
    final image = await boundary.toImage(pixelRatio: 2);
    final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
    final file = File('$_outDir/$name.png')..createSync(recursive: true);
    file.writeAsBytesSync(bytes!.buffer.asUint8List());
  });
}

void main() {
  setUpAll(_loadFonts);

  Future<LocalStore> freshStore({String? language, List<String> goals = const []}) async {
    SharedPreferences.setMockInitialValues({if (language != null) LocalStore.localeKey: language});
    final store = LocalStore(vault: FakeGoalVault());
    await store.load();
    for (final goal in goals) {
      await store.addGoal(goal);
    }
    return store;
  }

  Future<void> pumpApp(WidgetTester tester, LocalStore store, {bool fail = false, double textScale = 1}) async {
    tester.view.physicalSize = const Size(1080, 2280); // 360 x 760 dp
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(RepaintBoundary(
      key: const ValueKey('shot'),
      child: MediaQuery(
        data: MediaQueryData(size: const Size(360, 760), textScaler: TextScaler.linear(textScale)),
        child: HatuaApp(store: store, repository: fakeRepository(fail: fail)),
      ),
    ));
    await tester.pumpAndSettle();
  }

  Future<void> openTab(WidgetTester tester, IconData icon) async {
    await tester.tap(find.descendant(of: find.byType(NavigationBar), matching: find.byIcon(icon)));
    await tester.pumpAndSettle();
  }

  testWidgets('en screens', (tester) async {
    final store = await freshStore(goals: ['Prepare my CV', 'Visit the county youth office']);
    await store.toggleGoal(store.goals.first.id);
    await pumpApp(tester, store);
    await _shoot(tester, '01_home_en');
    await openTab(tester, Icons.work_outline);
    await _shoot(tester, '02_explore_en');
    await tester.drag(find.byType(Scrollable).first, const Offset(0, -700));
    await _shoot(tester, '03_explore_cards_en');
    await openTab(tester, Icons.volunteer_activism_outlined);
    await _shoot(tester, '04_support_en');
    await openTab(tester, Icons.flag_outlined);
    await _shoot(tester, '05_plan_en');
    await openTab(tester, Icons.settings_outlined);
    await _shoot(tester, '06_settings_en');
  });

  testWidgets('offline support', (tester) async {
    await pumpApp(tester, await freshStore(), fail: true);
    await openTab(tester, Icons.volunteer_activism_outlined);
    await tester.drag(find.byType(Scrollable).first, const Offset(0, -600));
    await _shoot(tester, '07_support_offline_en');
  });

  testWidgets('sw screens', (tester) async {
    await pumpApp(tester, await freshStore(language: 'sw'));
    await _shoot(tester, '08_home_sw');
    await openTab(tester, Icons.work_outline);
    await tester.drag(find.byType(Scrollable).first, const Offset(0, -700));
    await _shoot(tester, '09_explore_cards_sw');
    await openTab(tester, Icons.volunteer_activism_outlined);
    await _shoot(tester, '10_support_sw');
  });

  testWidgets('large text', (tester) async {
    await pumpApp(tester, await freshStore(), textScale: 2);
    await openTab(tester, Icons.work_outline);
    await tester.drag(find.byType(Scrollable).first, const Offset(0, -1400));
    await _shoot(tester, '11_explore_200pct_en');
  });
}
