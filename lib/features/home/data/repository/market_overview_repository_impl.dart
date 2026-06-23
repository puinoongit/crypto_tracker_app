import 'package:crypto_tracker_app/core/cache/cache_policy.dart';
import 'package:crypto_tracker_app/core/error/failure.dart';
import 'package:crypto_tracker_app/core/error/failure_mapper.dart';
import 'package:crypto_tracker_app/core/network/network_info.dart';
import 'package:crypto_tracker_app/core/utils/result.dart';
import 'package:crypto_tracker_app/features/home/domain/entity/global_market.dart';
import 'package:crypto_tracker_app/features/home/domain/entity/trending_coin.dart';
import 'package:crypto_tracker_app/features/home/domain/repository/market_overview_repository.dart';
import 'package:crypto_tracker_app/features/home/data/datasource/market_overview_local_datasource.dart';
import 'package:crypto_tracker_app/features/home/data/datasource/market_overview_remote_datasource.dart';

/// Offline-first repository for the overview header (global + trending),
/// reusing the 10-minute market TTL.
class MarketOverviewRepositoryImpl implements MarketOverviewRepository {
  const MarketOverviewRepositoryImpl({
    required MarketOverviewRemoteDataSource remote,
    required MarketOverviewLocalDataSource local,
    required NetworkInfo networkInfo,
  }) : _remote = remote,
       _local = local,
       _networkInfo = networkInfo;

  final MarketOverviewRemoteDataSource _remote;
  final MarketOverviewLocalDataSource _local;
  final NetworkInfo _networkInfo;

  @override
  Future<Result<GlobalMarket>> getGlobalMarket({
    bool forceRefresh = false,
  }) async {
    if (!forceRefresh) {
      final cached = _local.readGlobal();
      if (cached != null && !cached.isExpired(CachePolicy.marketTtl)) {
        return Result.ok(cached.data.toEntity());
      }
    }

    if (!await _networkInfo.isConnected) {
      final cached = _local.readGlobal();
      return cached != null
          ? Result.ok(cached.data.toEntity())
          : const Result.err(CacheFailure());
    }

    try {
      final dto = await _remote.fetchGlobalMarket();
      await _local.cacheGlobal(dto);
      return Result.ok(dto.toEntity());
    } catch (error) {
      final cached = _local.readGlobal();
      return cached != null
          ? Result.ok(cached.data.toEntity())
          : Result.err(mapExceptionToFailure(error));
    }
  }

  @override
  Future<Result<List<TrendingCoin>>> getTrendingCoins({
    bool forceRefresh = false,
  }) async {
    if (!forceRefresh) {
      final cached = _local.readTrending();
      if (cached != null && !cached.isExpired(CachePolicy.marketTtl)) {
        return Result.ok(cached.data.map((d) => d.toEntity()).toList());
      }
    }

    if (!await _networkInfo.isConnected) {
      final cached = _local.readTrending();
      return cached != null
          ? Result.ok(cached.data.map((d) => d.toEntity()).toList())
          : const Result.err(CacheFailure());
    }

    try {
      final dtos = await _remote.fetchTrendingCoins();
      await _local.cacheTrending(dtos);
      return Result.ok(dtos.map((d) => d.toEntity()).toList());
    } catch (error) {
      final cached = _local.readTrending();
      return cached != null
          ? Result.ok(cached.data.map((d) => d.toEntity()).toList())
          : Result.err(mapExceptionToFailure(error));
    }
  }
}
