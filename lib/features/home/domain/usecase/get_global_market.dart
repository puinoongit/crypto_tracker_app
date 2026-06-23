import 'package:crypto_tracker_app/core/utils/result.dart';
import 'package:crypto_tracker_app/features/home/domain/entity/global_market.dart';
import 'package:crypto_tracker_app/features/home/domain/repository/market_overview_repository.dart';

/// Fetches the global market summary for the header card.
class GetGlobalMarket {
  const GetGlobalMarket(this._repository);

  final MarketOverviewRepository _repository;

  Future<Result<GlobalMarket>> call({bool forceRefresh = false}) =>
      _repository.getGlobalMarket(forceRefresh: forceRefresh);
}
