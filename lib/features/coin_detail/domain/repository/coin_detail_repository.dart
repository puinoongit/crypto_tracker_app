import 'package:crypto_tracker_app/core/utils/result.dart';
import 'package:crypto_tracker_app/features/coin_detail/domain/entity/coin_detail.dart';

/// Domain contract for fetching a single coin's details (offline-first).
abstract interface class CoinDetailRepository {
  Future<Result<CoinDetail>> getCoinDetail(String coinId, {bool forceRefresh});

  /// Cached detail regardless of TTL — used for stale-while-revalidate UI.
  CoinDetail? peekCached(String coinId);
}
