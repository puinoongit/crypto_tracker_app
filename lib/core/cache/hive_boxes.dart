import 'package:hive_flutter/hive_flutter.dart';

/// Names of the Hive boxes used across the app. Kept as constants to avoid
/// stringly-typed mistakes and to document the storage surface in one place.
abstract final class HiveBoxes {
  static const String market = 'market_cache';
  static const String coinDetail = 'coin_detail_cache';
  static const String favorites = 'favorites';
  static const String settings = 'settings';
}

/// Initializes Hive and opens every box the app needs.
///
/// We deliberately store JSON-encoded strings rather than registering
/// `TypeAdapter`s: it keeps the persistence format transparent, avoids code
/// generation, and means DTO shape changes don't require schema migrations.
abstract final class HiveInitializer {
  static Future<void> init() async {
    await Hive.initFlutter();
    await Future.wait([
      Hive.openBox<String>(HiveBoxes.market),
      Hive.openBox<String>(HiveBoxes.coinDetail),
      Hive.openBox<String>(HiveBoxes.favorites),
      Hive.openBox<String>(HiveBoxes.settings),
    ]);
  }
}
