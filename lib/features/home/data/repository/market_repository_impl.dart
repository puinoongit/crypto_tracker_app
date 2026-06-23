import 'package:crypto_tracker_app/core/cache/cache_policy.dart';
import 'package:crypto_tracker_app/core/error/failure.dart';
import 'package:crypto_tracker_app/core/error/failure_mapper.dart';
import 'package:crypto_tracker_app/core/network/network_info.dart';
import 'package:crypto_tracker_app/core/utils/result.dart';
import 'package:crypto_tracker_app/features/home/domain/entity/coin.dart';
import 'package:crypto_tracker_app/features/home/domain/repository/market_repository.dart';
import 'package:crypto_tracker_app/features/home/data/datasource/market_local_datasource.dart';
import 'package:crypto_tracker_app/features/home/data/datasource/market_remote_datasource.dart';
import 'package:crypto_tracker_app/features/home/data/dto/coin_market_dto.dart';

/// Coordinates remote, cache, and connectivity to implement the offline-first
/// strategy from the spec:
///   1. Serve a still-fresh first page from cache (within the 10-min TTL).
///   2. Otherwise fetch from network and refresh the cache.
///   3. When offline (or on transient failure), fall back to cached data.
///   4. Map all data-layer exceptions to domain [Failure]s.
class MarketRepositoryImpl implements MarketRepository {
  const MarketRepositoryImpl({
    required MarketRemoteDataSource remote,
    required MarketLocalDataSource local,
    required NetworkInfo networkInfo,
  }) : _remote = remote,
       _local = local,
       _networkInfo = networkInfo;

  final MarketRemoteDataSource _remote;
  final MarketLocalDataSource _local;
  final NetworkInfo _networkInfo;

  List<Coin> _toEntities(List<CoinMarketDto> dtos) =>
      dtos.map((d) => d.toEntity()).toList(growable: false);

  @override
  Future<Result<List<Coin>>> getMarketCoins({
    required int page,
    required int perPage,
    bool forceRefresh = false,
    Duration cacheTtl = CachePolicy.marketTtl,
  }) async {
    if (!forceRefresh) {
      final cached = _local.readPage(page);
      if (cached != null && !cached.isExpired(cacheTtl)) {
        return Result.ok(_toEntities(cached.data));
      }
    }
    if (!await _networkInfo.isConnected) {
      return _cachedOrFailure(page, const NoInternetFailure());
    }

    // 3. Online → fetch, cache, return. On failure, gracefully degrade.
    try {
      final dtos = await _remote.fetchMarketCoins(page: page, perPage: perPage);
      await _local.cachePage(page, dtos);
      return Result.ok(_toEntities(dtos));
    } catch (error) {
      return _cachedOrFailure(page, mapExceptionToFailure(error));
    }
  }

  /// Returns cached data for [page] if present (regardless of TTL, since stale
  /// data beats nothing when the network is unavailable); otherwise [fallback].
  Result<List<Coin>> _cachedOrFailure(int page, Failure fallback) {
    final cached = _local.readPage(page);
    if (cached != null) return Result.ok(_toEntities(cached.data));
    // No cache and no network → surface a cache failure for the very first
    // page, otherwise the original failure (pagination can't fall back).
    return Result.err(page == 1 ? const CacheFailure() : fallback);
  }

  @override
  Future<Result<List<Coin>>> getMarketCoinsByIds({
    required List<String> ids,
    bool forceRefresh = false,
  }) async {
    if (ids.isEmpty) return const Result.ok([]);

    if (!forceRefresh) {
      final cached = _local.readFavorites();
      if (cached != null && !cached.isExpired(CachePolicy.marketTtl)) {
        final coins = _orderByIds(_toEntities(cached.data), ids);
        if (_coversAllIds(coins, ids)) {
          return Result.ok(coins);
        }
      }
    }

    if (!await _networkInfo.isConnected) {
      return _favoritesCachedOrFailure(ids, const NoInternetFailure());
    }

    try {
      final dtos = await _remote.fetchMarketCoinsByIds(ids: ids);
      await _local.cacheFavorites(dtos);
      return Result.ok(_orderByIds(_toEntities(dtos), ids));
    } catch (error) {
      return _favoritesCachedOrFailure(ids, mapExceptionToFailure(error));
    }
  }

  List<Coin> _orderByIds(List<Coin> coins, List<String> ids) {
    final byId = {for (final coin in coins) coin.id: coin};
    return [
      for (final id in ids)
        if (byId.containsKey(id)) byId[id]!,
    ];
  }

  bool _coversAllIds(List<Coin> coins, List<String> ids) {
    final found = coins.map((c) => c.id).toSet();
    return ids.every(found.contains);
  }

  Result<List<Coin>> _favoritesCachedOrFailure(
    List<String> ids,
    Failure fallback,
  ) {
    final favoritesCache = _local.readFavorites();
    if (favoritesCache != null) {
      final ordered = _orderByIds(_toEntities(favoritesCache.data), ids);
      if (ordered.isNotEmpty) return Result.ok(ordered);
    }

    final fromPages = _local.findCoinsInCachedPages(ids.toSet());
    if (fromPages.isNotEmpty) {
      return Result.ok(_orderByIds(_toEntities(fromPages), ids));
    }

    return Result.err(
      fallback is NoInternetFailure ? const CacheFailure() : fallback,
    );
  }
}
