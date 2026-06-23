import 'package:equatable/equatable.dart';

import 'package:crypto_tracker_app/core/error/failure.dart';
import 'package:crypto_tracker_app/features/home/domain/entity/coin.dart';

enum FavoritesStatus { initial, loading, success, error }

/// Immutable state for the favorites screen.
class FavoritesState extends Equatable {
  const FavoritesState({
    this.status = FavoritesStatus.initial,
    this.coins = const [],
    this.failure,
    this.isRefreshing = false,
  });

  final FavoritesStatus status;
  final List<Coin> coins;
  final Failure? failure;
  final bool isRefreshing;

  FavoritesState copyWith({
    FavoritesStatus? status,
    List<Coin>? coins,
    Failure? failure,
    bool clearFailure = false,
    bool? isRefreshing,
  }) {
    return FavoritesState(
      status: status ?? this.status,
      coins: coins ?? this.coins,
      failure: clearFailure ? null : (failure ?? this.failure),
      isRefreshing: isRefreshing ?? this.isRefreshing,
    );
  }

  @override
  List<Object?> get props => [status, coins, failure, isRefreshing];
}
