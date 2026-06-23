import 'package:crypto_tracker_app/core/usecase/usecase.dart';
import 'package:crypto_tracker_app/core/utils/result.dart';
import 'package:crypto_tracker_app/features/coin_detail/domain/entity/coin_detail.dart';
import 'package:crypto_tracker_app/features/coin_detail/domain/repository/coin_detail_repository.dart';

class CoinDetailParams {
  const CoinDetailParams({required this.coinId, this.forceRefresh = false});
  final String coinId;
  final bool forceRefresh;
}

class GetCoinDetail implements UseCase<CoinDetail, CoinDetailParams> {
  const GetCoinDetail(this._repository);

  final CoinDetailRepository _repository;

  @override
  Future<Result<CoinDetail>> call(CoinDetailParams params) {
    return _repository.getCoinDetail(
      params.coinId,
      forceRefresh: params.forceRefresh,
    );
  }

  CoinDetail? peekCached(String coinId) => _repository.peekCached(coinId);
}
