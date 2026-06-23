import 'package:crypto_tracker_app/core/cache/cache_policy.dart';
import 'package:crypto_tracker_app/core/error/failure.dart';
import 'package:crypto_tracker_app/core/error/failure_mapper.dart';
import 'package:crypto_tracker_app/core/network/network_info.dart';
import 'package:crypto_tracker_app/core/utils/result.dart';
import 'package:crypto_tracker_app/features/coin_detail/domain/entity/coin_detail.dart';
import 'package:crypto_tracker_app/features/coin_detail/domain/repository/coin_detail_repository.dart';
import 'package:crypto_tracker_app/features/coin_detail/data/datasource/coin_detail_local_datasource.dart';
import 'package:crypto_tracker_app/features/coin_detail/data/datasource/coin_detail_remote_datasource.dart';

/// Offline-first coin-detail repository.
///
/// Mirrors the market strategy but with a 30-minute TTL: fresh cache is served
/// without a network hit; otherwise fetch + cache; offline/failed reads fall
/// back to any cached copy before surfacing a [Failure].
class CoinDetailRepositoryImpl implements CoinDetailRepository {
  const CoinDetailRepositoryImpl({
    required CoinDetailRemoteDataSource remote,
    required CoinDetailLocalDataSource local,
    required NetworkInfo networkInfo,
  }) : _remote = remote,
       _local = local,
       _networkInfo = networkInfo;

  final CoinDetailRemoteDataSource _remote;
  final CoinDetailLocalDataSource _local;
  final NetworkInfo _networkInfo;

  @override
  Future<Result<CoinDetail>> getCoinDetail(
    String coinId, {
    bool forceRefresh = false,
  }) async {
    if (!forceRefresh) {
      final cached = _local.read(coinId);
      if (cached != null && !cached.isExpired(CachePolicy.coinDetailTtl)) {
        return Result.ok(cached.data.toEntity());
      }
    }

    if (!await _networkInfo.isConnected) {
      return _cachedOrFailure(coinId, const NoInternetFailure());
    }

    try {
      final dto = await _remote.fetchCoinDetail(coinId);
      await _local.cache(dto);
      return Result.ok(dto.toEntity());
    } catch (error) {
      return _cachedOrFailure(coinId, mapExceptionToFailure(error));
    }
  }

  Result<CoinDetail> _cachedOrFailure(String coinId, Failure fallback) {
    final cached = _local.read(coinId);
    if (cached != null) return Result.ok(cached.data.toEntity());
    return Result.err(
      fallback is NoInternetFailure ? const CacheFailure() : fallback,
    );
  }

  @override
  CoinDetail? peekCached(String coinId) {
    final cached = _local.read(coinId);
    return cached?.data.toEntity();
  }
}
