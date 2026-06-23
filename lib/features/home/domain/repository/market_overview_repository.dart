import 'package:crypto_tracker_app/core/utils/result.dart';
import 'package:crypto_tracker_app/features/home/domain/entity/global_market.dart';
import 'package:crypto_tracker_app/features/home/domain/entity/trending_coin.dart';

/// Domain contract for the markets-overview header data (global stats +
/// trending coins). Offline-first, same as the rest of the data layer.
abstract interface class MarketOverviewRepository {
  Future<Result<GlobalMarket>> getGlobalMarket({bool forceRefresh});

  Future<Result<List<TrendingCoin>>> getTrendingCoins({bool forceRefresh});
}
