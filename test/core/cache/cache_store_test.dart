import 'dart:io';

import 'package:crypto_tracker_app/core/cache/cache_store.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';

void main() {
  late Directory tempDir;
  late Box<String> box;
  late CacheStore store;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('cache_test');
    Hive.init(tempDir.path);
    box = await Hive.openBox<String>('test_box');
    store = CacheStore(box);
  });

  tearDown(() async {
    await box.deleteFromDisk();
    await Hive.close();
    await tempDir.delete(recursive: true);
  });

  group('CacheStore', () {
    test('round-trips an object payload with a save timestamp', () async {
      await store.write('k', {'name': 'Bitcoin', 'rank': 1});

      final entry = store.readObject('k');
      expect(entry, isNotNull);
      expect(entry!.data['name'], 'Bitcoin');
      expect(
        entry.savedAt.difference(DateTime.now()).inSeconds.abs(),
        lessThan(5),
      );
    });

    test('round-trips a list payload', () async {
      await store.write('list', [
        {'id': 'a'},
        {'id': 'b'},
      ]);

      final entry = store.readList('list');
      expect(entry!.data, hasLength(2));
    });

    test('returns null for a missing key', () {
      expect(store.read('absent'), isNull);
    });

    test('CachedData.isExpired honors the TTL', () {
      final fresh = CachedData(data: 1, savedAt: DateTime.now());
      final old = CachedData(
        data: 1,
        savedAt: DateTime.now().subtract(const Duration(minutes: 20)),
      );

      expect(fresh.isExpired(const Duration(minutes: 10)), isFalse);
      expect(old.isExpired(const Duration(minutes: 10)), isTrue);
      expect(old.isExpired(null), isFalse, reason: 'null TTL never expires');
    });

    test('drops and reports corrupt entries as null', () async {
      await box.put('bad', 'not-json{');
      expect(store.read('bad'), isNull);
      expect(box.containsKey('bad'), isFalse);
    });
  });
}
