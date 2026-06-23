import 'package:crypto_tracker_app/core/cache/cache_store.dart';
import 'package:crypto_tracker_app/features/home/data/dto/coin_market_dto.dart';

/// Persists market pages to the local cache (Hive) for offline-first reads.
///
/// Each page is stored under its own key so paginated data survives across
/// launches and individual pages can expire independently.
abstract interface class MarketLocalDataSource {
  Future<void> cachePage(int page, List<CoinMarketDto> coins);

  /// Returns the cached page wrapped with its save time, or `null` if absent.
  CachedData<List<CoinMarketDto>>? readPage(int page);

  Future<void> cacheFavorites(List<CoinMarketDto> coins);

  CachedData<List<CoinMarketDto>>? readFavorites();

  /// Scans sequentially cached market pages for the given [ids].
  List<CoinMarketDto> findCoinsInCachedPages(Set<String> ids);
}

class MarketLocalDataSourceImpl implements MarketLocalDataSource {
  const MarketLocalDataSourceImpl(this._cache);

  final CacheStore _cache;

  static const _favoritesKey = 'favorites_market';

  String _key(int page) => 'market_page_$page';

  @override
  Future<void> cachePage(int page, List<CoinMarketDto> coins) {
    final json = coins.map((c) => c.toJson()).toList();
    return _cache.write(_key(page), json);
  }

  @override
  CachedData<List<CoinMarketDto>>? readPage(int page) {
    final entry = _cache.readList(_key(page));
    if (entry == null) return null;
    final coins = entry.data
        .map((e) => CoinMarketDto.fromJson((e as Map).cast<String, dynamic>()))
        .toList(growable: false);
    return CachedData(data: coins, savedAt: entry.savedAt);
  }

  @override
  Future<void> cacheFavorites(List<CoinMarketDto> coins) {
    final json = coins.map((c) => c.toJson()).toList();
    return _cache.write(_favoritesKey, json);
  }

  @override
  CachedData<List<CoinMarketDto>>? readFavorites() {
    final entry = _cache.readList(_favoritesKey);
    if (entry == null) return null;
    final coins = entry.data
        .map((e) => CoinMarketDto.fromJson((e as Map).cast<String, dynamic>()))
        .toList(growable: false);
    return CachedData(data: coins, savedAt: entry.savedAt);
  }

  @override
  List<CoinMarketDto> findCoinsInCachedPages(Set<String> ids) {
    if (ids.isEmpty) return const [];

    final found = <String, CoinMarketDto>{};
    for (var page = 1; page <= 50; page++) {
      final cached = readPage(page);
      if (cached == null) break;

      for (final coin in cached.data) {
        if (ids.contains(coin.id)) {
          found[coin.id] = coin;
        }
      }
      if (found.length == ids.length) break;
    }

    return found.values.toList(growable: false);
  }
}
