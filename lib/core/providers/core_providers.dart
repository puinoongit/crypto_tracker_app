import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';

import 'package:crypto_tracker_app/core/cache/cache_store.dart';
import 'package:crypto_tracker_app/core/cache/hive_boxes.dart';
import 'package:crypto_tracker_app/core/network/dio_client.dart';
import 'package:crypto_tracker_app/core/network/network_info.dart';

/// Cross-cutting providers (networking, connectivity, cache stores).
///
/// Hive boxes are opened asynchronously *before* `runApp`, then injected here
/// via `ProviderScope` overrides. The unimplemented defaults make it a loud
/// error if an override is ever forgotten, and let tests swap in fakes easily.

// ── Raw box providers (overridden at startup / in tests) ────────────────────
final marketBoxProvider = Provider<Box<String>>(
  (ref) => throw UnimplementedError('marketBoxProvider must be overridden'),
);
final coinDetailBoxProvider = Provider<Box<String>>(
  (ref) => throw UnimplementedError('coinDetailBoxProvider must be overridden'),
);
final favoritesBoxProvider = Provider<Box<String>>(
  (ref) => throw UnimplementedError('favoritesBoxProvider must be overridden'),
);
final settingsBoxProvider = Provider<Box<String>>(
  (ref) => throw UnimplementedError('settingsBoxProvider must be overridden'),
);

/// Builds the [ProviderScope] overrides from the already-opened boxes.
List<Override> buildBoxOverrides() => [
  marketBoxProvider.overrideWithValue(Hive.box<String>(HiveBoxes.market)),
  coinDetailBoxProvider.overrideWithValue(
    Hive.box<String>(HiveBoxes.coinDetail),
  ),
  favoritesBoxProvider.overrideWithValue(Hive.box<String>(HiveBoxes.favorites)),
  settingsBoxProvider.overrideWithValue(Hive.box<String>(HiveBoxes.settings)),
];

// ── Cache stores ────────────────────────────────────────────────────────────
final marketCacheProvider = Provider<CacheStore>(
  (ref) => CacheStore(ref.watch(marketBoxProvider)),
);
final coinDetailCacheProvider = Provider<CacheStore>(
  (ref) => CacheStore(ref.watch(coinDetailBoxProvider)),
);
final favoritesCacheProvider = Provider<CacheStore>(
  (ref) => CacheStore(ref.watch(favoritesBoxProvider)),
);

// ── Networking ──────────────────────────────────────────────────────────────
final dioProvider = Provider<Dio>((ref) {
  final dio = DioClient.create(enableLogging: kDebugMode);
  ref.onDispose(dio.close);
  return dio;
});

final connectivityProvider = Provider<Connectivity>((ref) => Connectivity());

final networkInfoProvider = Provider<NetworkInfo>(
  (ref) => NetworkInfoImpl(ref.watch(connectivityProvider)),
);

/// Streams the live online/offline status, used to drive the offline banner.
final connectivityStatusProvider = StreamProvider<bool>((ref) async* {
  final networkInfo = ref.watch(networkInfoProvider);
  yield await networkInfo.isConnected;
  yield* networkInfo.onStatusChange;
});
