import 'package:crypto_tracker_app/core/usecase/usecase.dart';
import 'package:crypto_tracker_app/core/utils/result.dart';
import 'package:crypto_tracker_app/features/home/domain/entity/coin.dart';
import 'package:crypto_tracker_app/features/home/domain/repository/market_repository.dart';

/// Parameters for [GetMarketCoinsByIds].
class MarketCoinsByIdsParams {
  const MarketCoinsByIdsParams({required this.ids, this.forceRefresh = false});

  final List<String> ids;
  final bool forceRefresh;
}

/// Fetches market data for a specific set of coin ids (used by Favorites).
class GetMarketCoinsByIds
    implements UseCase<List<Coin>, MarketCoinsByIdsParams> {
  const GetMarketCoinsByIds(this._repository);

  final MarketRepository _repository;

  @override
  Future<Result<List<Coin>>> call(MarketCoinsByIdsParams params) {
    return _repository.getMarketCoinsByIds(
      ids: params.ids,
      forceRefresh: params.forceRefresh,
    );
  }
}
