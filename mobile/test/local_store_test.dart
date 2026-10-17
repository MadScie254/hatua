import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hatua_app/src/data/catalog_repository.dart';
import 'package:hatua_app/src/data/local_store.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
    FlutterSecureStorage.setMockInitialValues({});
  });

  test('goals persist in secure storage, not SharedPreferences', () async {
    final store = LocalStore();
    await store.load();
    await store.addGoal('  Visit the county youth office  ');
    await store.toggleGoal(store.goals.single.id);

    final reloaded = LocalStore();
    await reloaded.load();
    expect(reloaded.goals.single.title, 'Visit the county youth office');
    expect(reloaded.goals.single.isDone, isTrue);

    final prefs = await SharedPreferences.getInstance();
    for (final key in prefs.getKeys()) {
      expect(prefs.get(key).toString(), isNot(contains('youth office')),
          reason: 'goal text must never be written to unencrypted preferences');
    }
  });

  test('rejects empty and over-long goals', () async {
    final store = LocalStore();
    await store.load();
    await store.addGoal('   ');
    await store.addGoal('x' * (LocalStore.maxGoalLength + 1));
    expect(store.goals, isEmpty);
  });

  test('county and language accept only known values', () async {
    final store = LocalStore();
    await store.load();
    await store.setCounty('Kisumu');
    await store.setLanguageCode('sw');
    expect(store.county, 'Kisumu');
    expect(store.languageCode, 'sw');
    await store.setCounty('Atlantis');
    await store.setLanguageCode('fr');
    expect(store.county, isNull);
    expect(store.languageCode, isNull);
  });

  test('ignores tampered preference values on load', () async {
    SharedPreferences.setMockInitialValues({LocalStore.countyKey: 'Atlantis', LocalStore.localeKey: 'xx'});
    final store = LocalStore();
    await store.load();
    expect(store.county, isNull);
    expect(store.locale, isNull);
  });

  test('clearAll removes every HATUA value from the device', () async {
    SharedPreferences.setMockInitialValues({
      for (final key in CatalogRepository.allCacheKeys) key: key.endsWith('fetchedAt') ? 1 : '[]',
    });
    final store = LocalStore();
    await store.load();
    await store.addGoal('Private');
    await store.toggleBookmark('o1');
    await store.setCounty('Nairobi');
    await store.setLanguageCode('sw');

    await store.clearAll();

    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getKeys(), isEmpty);
    expect(await const FlutterSecureStorage().read(key: LocalStore.goalsKey), isNull);
    expect(store.goals, isEmpty);
    expect(store.isSaved('o1'), isFalse);
    expect(store.county, isNull);
    expect(store.languageCode, isNull);
  });
}
