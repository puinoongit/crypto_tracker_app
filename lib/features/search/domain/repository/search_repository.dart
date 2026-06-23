import 'package:crypto_tracker_app/core/utils/result.dart';
import 'package:crypto_tracker_app/features/home/domain/entity/coin.dart';

/// Domain contract for server-side coin search.
abstract interface class SearchRepository {
  /// Resolves ids via `/search`, hydrates market rows, caches by query.
  Future<Result<List<Coin>>> searchCoins({
    required String query,
    bool forceRefresh = false,
  });
}
