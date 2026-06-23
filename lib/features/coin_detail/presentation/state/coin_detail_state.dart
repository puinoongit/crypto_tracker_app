import 'package:equatable/equatable.dart';

import 'package:crypto_tracker_app/core/error/failure.dart';
import 'package:crypto_tracker_app/features/coin_detail/domain/entity/coin_detail.dart';

enum CoinDetailStatus { loading, success, error }

/// Immutable state for the coin detail screen.
class CoinDetailState extends Equatable {
  const CoinDetailState({
    this.status = CoinDetailStatus.loading,
    this.detail,
    this.failure,
    this.isRefreshing = false,
  });

  final CoinDetailStatus status;
  final CoinDetail? detail;
  final Failure? failure;
  final bool isRefreshing;

  CoinDetailState copyWith({
    CoinDetailStatus? status,
    CoinDetail? detail,
    Failure? failure,
    bool clearFailure = false,
    bool? isRefreshing,
  }) {
    return CoinDetailState(
      status: status ?? this.status,
      detail: detail ?? this.detail,
      failure: clearFailure ? null : (failure ?? this.failure),
      isRefreshing: isRefreshing ?? this.isRefreshing,
    );
  }

  @override
  List<Object?> get props => [status, detail, failure, isRefreshing];
}
