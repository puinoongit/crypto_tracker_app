import 'package:crypto_tracker_app/core/cache/cache_store.dart';
import 'package:crypto_tracker_app/features/home/data/dto/global_market_dto.dart';
import 'package:crypto_tracker_app/features/home/data/dto/trending_coin_dto.dart';

/// Caches the overview header data (global stats + trending) for offline reads.
abstract interface class MarketOverviewLocalDataSource {
  Future<void> cacheGlobal(GlobalMarketDto global);
  CachedData<GlobalMarketDto>? readGlobal();

  Future<void> cacheTrending(List<TrendingCoinDto> trending);
  CachedData<List<TrendingCoinDto>>? readTrending();
}

class MarketOverviewLocalDataSourceImpl
    implements MarketOverviewLocalDataSource {
  const MarketOverviewLocalDataSourceImpl(this._cache);

  final CacheStore _cache;

  static const _globalKey = 'global_market';
  static const _trendingKey = 'trending_coins';

  @override
  Future<void> cacheGlobal(GlobalMarketDto global) =>
      _cache.write(_globalKey, global.toJson());

  @override
  CachedData<GlobalMarketDto>? readGlobal() {
    final entry = _cache.readObject(_globalKey);
    if (entry == null) return null;
    return CachedData(
      data: GlobalMarketDto.fromJson(entry.data),
      savedAt: entry.savedAt,
    );
  }

  @override
  Future<void> cacheTrending(List<TrendingCoinDto> trending) =>
      _cache.write(_trendingKey, trending.map((t) => t.toJson()).toList());

  @override
  CachedData<List<TrendingCoinDto>>? readTrending() {
    final entry = _cache.readList(_trendingKey);
    if (entry == null) return null;
    final coins = entry.data
        .map(
          (e) => TrendingCoinDto.fromJson((e as Map).cast<String, dynamic>()),
        )
        .toList(growable: false);
    return CachedData(data: coins, savedAt: entry.savedAt);
  }
}
