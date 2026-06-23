import 'package:crypto_tracker_app/core/utils/result.dart';
import 'package:crypto_tracker_app/core/cache/cache_policy.dart';
import 'package:crypto_tracker_app/features/home/domain/entity/coin.dart';

/// Domain contract for fetching market data.
///
/// The domain layer defines *what* it needs; the data layer decides *how*
/// (remote + cache). This inversion keeps use cases independent of Dio/Hive.
abstract interface class MarketRepository {
  /// Returns a single page of market coins, ordered by market-cap rank.
  ///
  /// Implementations fetch from the network when online and fall back to the
  /// cache when offline (or on transient failure for the first page). When
  /// [forceRefresh] is `false`, a still-fresh cached first page may be served
  /// without hitting the network (honoring the cache TTL); pull-to-refresh
  /// passes `true` to always bypass the cache. [cacheTtl] controls how long a
  /// cached page is reused when [forceRefresh] is `false` (polling uses a
  /// shorter TTL than pagination).
  Future<Result<List<Coin>>> getMarketCoins({
    required int page,
    required int perPage,
    bool forceRefresh = false,
    Duration cacheTtl = CachePolicy.marketTtl,
  });

  /// Returns market data for the given [ids] (price + sparkline), preserving
  /// the order of [ids]. Used by the Favorites tab to fetch only starred coins.
  Future<Result<List<Coin>>> getMarketCoinsByIds({
    required List<String> ids,
    bool forceRefresh,
  });
}
