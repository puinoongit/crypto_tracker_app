import 'package:crypto_tracker_app/core/usecase/usecase.dart';
import 'package:crypto_tracker_app/core/utils/result.dart';
import 'package:crypto_tracker_app/core/cache/cache_policy.dart';
import 'package:crypto_tracker_app/features/home/domain/entity/coin.dart';
import 'package:crypto_tracker_app/features/home/domain/repository/market_repository.dart';

/// Parameters for [GetMarketCoins].
class MarketPageParams {
  const MarketPageParams({
    required this.page,
    required this.perPage,
    this.forceRefresh = false,
    this.cacheTtl = CachePolicy.marketTtl,
  });
  final int page;
  final int perPage;
  final bool forceRefresh;
  final Duration cacheTtl;
}

/// Fetches one page of market coins. Thin by design — it exists so the
/// presentation layer expresses intent ("get the market") without knowing about
/// repositories, and so this step is independently testable and composable.
class GetMarketCoins implements UseCase<List<Coin>, MarketPageParams> {
  const GetMarketCoins(this._repository);

  final MarketRepository _repository;

  @override
  Future<Result<List<Coin>>> call(MarketPageParams params) {
    return _repository.getMarketCoins(
      page: params.page,
      perPage: params.perPage,
      forceRefresh: params.forceRefresh,
      cacheTtl: params.cacheTtl,
    );
  }
}
