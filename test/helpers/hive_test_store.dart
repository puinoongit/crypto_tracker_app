import 'dart:io';

import 'package:crypto_tracker_app/core/cache/cache_store.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';

/// Spins up a real, isolated Hive box backed by a temp directory and returns a
/// [CacheStore] over it. Registers teardown automatically.
///
/// Using a real box (rather than a mock) gives the local data-source tests
/// genuine serialization coverage.
Future<CacheStore> openTestCacheStore() async {
  final tempDir = await Directory.systemTemp.createTemp('hive_ds_test');
  Hive.init(tempDir.path);
  final box = await Hive.openBox<String>(
    'box_${DateTime.now().microsecondsSinceEpoch}',
  );

  addTearDown(() async {
    await box.deleteFromDisk();
    await Hive.close();
    await tempDir.delete(recursive: true);
  });

  return CacheStore(box);
}
