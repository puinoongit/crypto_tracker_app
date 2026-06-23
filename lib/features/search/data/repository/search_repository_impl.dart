import 'package:crypto_tracker_app/core/config/api_config.dart';
import 'package:crypto_tracker_app/core/cache/cache_policy.dart';
import 'package:crypto_tracker_app/core/error/failure.dart';
import 'package:crypto_tracker_app/core/error/failure_mapper.dart';
import 'package:crypto_tracker_app/core/network/network_info.dart';
import 'package:crypto_tracker_app/core/utils/result.dart';
import 'package:crypto_tracker_app/features/home/data/dto/coin_market_dto.dart';
import 'package:crypto_tracker_app/features/home/domain/entity/coin.dart';
import 'package:crypto_tracker_app/features/search/data/datasource/search_local_datasource.dart';
import 'package:crypto_tracker_app/features/search/data/datasource/search_remote_datasource.dart';
import 'package:crypto_tracker_app/features/search/domain/repository/search_repository.dart';

class SearchRepositoryImpl implements SearchRepository {
  const SearchRepositoryImpl({
    required SearchRemoteDataSource remote,
    required SearchLocalDataSource local,
    required NetworkInfo networkInfo,
  }) : _remote = remote,
       _local = local,
       _networkInfo = networkInfo;

  final SearchRemoteDataSource _remote;
  final SearchLocalDataSource _local;
  final NetworkInfo _networkInfo;

  List<Coin> _toEntities(List<CoinMarketDto> dtos) =>
      dtos.map((d) => d.toEntity()).toList(growable: false);

  List<Coin> _orderByIds(List<Coin> coins, List<String> ids) {
    final byId = {for (final coin in coins) coin.id: coin};
    return [
      for (final id in ids)
        if (byId.containsKey(id)) byId[id]!,
    ];
  }

  @override
  Future<Result<List<Coin>>> searchCoins({
    required String query,
    bool forceRefresh = false,
  }) async {
    final normalized = query.trim();
    if (normalized.length < ApiConfig.searchMinLength) {
      return const Result.ok([]);
    }

    if (!forceRefresh) {
      final cached = _local.readSearchResults(normalized);
      if (cached != null && !cached.isExpired(CachePolicy.searchTtl)) {
        return Result.ok(_toEntities(cached.data));
      }
    }

    if (!await _networkInfo.isConnected) {
      return _searchCachedOrFailure(normalized, const NoInternetFailure());
    }

    try {
      final ids = await _remote.searchCoinIds(query: normalized);
      if (ids.isEmpty) return const Result.ok([]);

      final dtos = await _remote.fetchMarketCoinsByIds(ids: ids);
      await _local.cacheSearchResults(normalized, dtos);
      return Result.ok(_orderByIds(_toEntities(dtos), ids));
    } catch (error) {
      return _searchCachedOrFailure(normalized, mapExceptionToFailure(error));
    }
  }

  Result<List<Coin>> _searchCachedOrFailure(String query, Failure fallback) {
    final cached = _local.readSearchResults(query);
    if (cached != null) return Result.ok(_toEntities(cached.data));
    return Result.err(
      fallback is NoInternetFailure ? const CacheFailure() : fallback,
    );
  }
}
