import 'package:equatable/equatable.dart';

import 'package:crypto_tracker_app/core/error/failure.dart';
import 'package:crypto_tracker_app/features/home/domain/entity/coin.dart';

/// Status of the initial (full-screen) load.
enum HomeStatus { initial, loading, success, error }

/// Immutable UI state for the market list screen.
class HomeState extends Equatable {
  const HomeState({
    this.status = HomeStatus.initial,
    this.coins = const [],
    this.failure,
    this.page = 0,
    this.isLoadingMore = false,
    this.hasReachedEnd = false,
    this.isRefreshing = false,
  });

  final HomeStatus status;

  /// All coins loaded so far across pages (the source of truth).
  final List<Coin> coins;

  /// Failure for the *initial* load only (paging errors don't blank the screen).
  final Failure? failure;

  /// Highest page successfully loaded.
  final int page;

  final bool isLoadingMore;
  final bool hasReachedEnd;

  /// True only during an explicit pull-to-refresh (not pagination).
  final bool isRefreshing;

  HomeState copyWith({
    HomeStatus? status,
    List<Coin>? coins,
    Failure? failure,
    bool clearFailure = false,
    int? page,
    bool? isLoadingMore,
    bool? hasReachedEnd,
    bool? isRefreshing,
  }) {
    return HomeState(
      status: status ?? this.status,
      coins: coins ?? this.coins,
      failure: clearFailure ? null : (failure ?? this.failure),
      page: page ?? this.page,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      hasReachedEnd: hasReachedEnd ?? this.hasReachedEnd,
      isRefreshing: isRefreshing ?? this.isRefreshing,
    );
  }

  @override
  List<Object?> get props => [
    status,
    coins,
    failure,
    page,
    isLoadingMore,
    hasReachedEnd,
    isRefreshing,
  ];
}
