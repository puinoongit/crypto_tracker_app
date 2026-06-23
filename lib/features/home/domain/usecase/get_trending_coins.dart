import 'package:crypto_tracker_app/core/utils/result.dart';
import 'package:crypto_tracker_app/features/home/domain/entity/trending_coin.dart';
import 'package:crypto_tracker_app/features/home/domain/repository/market_overview_repository.dart';

/// Fetches the trending coins for the horizontal carousel.
class GetTrendingCoins {
  const GetTrendingCoins(this._repository);

  final MarketOverviewRepository _repository;

  Future<Result<List<TrendingCoin>>> call({bool forceRefresh = false}) =>
      _repository.getTrendingCoins(forceRefresh: forceRefresh);
}
