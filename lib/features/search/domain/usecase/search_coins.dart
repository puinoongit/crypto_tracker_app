import 'package:crypto_tracker_app/core/usecase/usecase.dart';
import 'package:crypto_tracker_app/core/utils/result.dart';
import 'package:crypto_tracker_app/features/home/domain/entity/coin.dart';
import 'package:crypto_tracker_app/features/search/domain/repository/search_repository.dart';

class SearchCoinsParams {
  const SearchCoinsParams({required this.query, this.forceRefresh = false});

  final String query;
  final bool forceRefresh;
}

/// Resolves coins across the full CoinGecko catalog (not just loaded pages).
class SearchCoins implements UseCase<List<Coin>, SearchCoinsParams> {
  const SearchCoins(this._repository);

  final SearchRepository _repository;

  @override
  Future<Result<List<Coin>>> call(SearchCoinsParams params) {
    return _repository.searchCoins(
      query: params.query,
      forceRefresh: params.forceRefresh,
    );
  }
}
