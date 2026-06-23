import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:crypto_tracker_app/core/config/api_config.dart';
import 'package:crypto_tracker_app/core/config/performance_config.dart';
import 'package:crypto_tracker_app/core/cache/cache_policy.dart';
import 'package:crypto_tracker_app/features/home/domain/usecase/get_market_coins.dart';
import 'package:crypto_tracker_app/features/home/presentation/home_providers.dart';
import 'package:crypto_tracker_app/features/home/presentation/state/home_state.dart';

/// Orchestrates the market list: initial load, pagination, refresh,
/// and optional foreground polling.
class HomeViewModel extends Notifier<HomeState> {
  late final GetMarketCoins _getMarketCoins;
  Timer? _pollTimer;
  int _pollGeneration = 0;
  bool _initialized = false;

  @override
  HomeState build() {
    _getMarketCoins = ref.watch(getMarketCoinsUseCaseProvider);

    ref.onDispose(() {
      _pollTimer?.cancel();
      _initialized = false;
    });

    if (!_initialized) {
      _initialized = true;
      return const HomeState();
    }

    return state;
  }

  /// Called by [homeMarketPollingProvider] — must not live in [build] or toggling
  /// live updates would rebuild this notifier and reset [HomeState].
  void setMarketPollingActive(bool active) {
    _syncPolling(active);
    if (!active && state.isRefreshing) {
      state = state.copyWith(isRefreshing: false);
    }
  }

  void _syncPolling(bool active) {
    _pollTimer?.cancel();
    _pollTimer = null;
    if (!active) {
      _pollGeneration++;
      return;
    }

    _pollTimer = Timer.periodic(ApiConfig.foregroundPollInterval, (_) {
      unawaited(_pollRefresh());
    });
  }

  /// Silent refresh for foreground polling — no pull-to-refresh UI.
  Future<void> _pollRefresh() async {
    final generation = _pollGeneration;
    if (state.isRefreshing ||
        state.isLoadingMore ||
        state.status != HomeStatus.success) {
      return;
    }

    final result = await _getMarketCoins(
      MarketPageParams(
        page: 1,
        perPage: ApiConfig.pageSize,
        cacheTtl: CachePolicy.marketPollTtl,
      ),
    );

    if (generation != _pollGeneration || state.isRefreshing) {
      return;
    }

    state = result.fold(
      (failure) => state,
      (coins) => state.copyWith(
        coins: coins,
        page: 1,
        hasReachedEnd: coins.length < ApiConfig.pageSize,
        isLoadingMore: false,
        clearFailure: true,
      ),
    );
  }

  Future<void> loadInitial() async {
    if (state.status == HomeStatus.loading) return;
    state = state.copyWith(status: HomeStatus.loading, clearFailure: true);

    final result = await _getMarketCoins(
      const MarketPageParams(page: 1, perPage: ApiConfig.pageSize),
    );

    state = result.fold(
      (failure) => state.copyWith(status: HomeStatus.error, failure: failure),
      (coins) => state.copyWith(
        status: HomeStatus.success,
        coins: coins,
        page: 1,
        hasReachedEnd: coins.length < ApiConfig.pageSize,
        clearFailure: true,
      ),
    );
  }

  Future<void> refresh() async {
    if (state.isRefreshing) return;

    state = state.copyWith(isRefreshing: true);
    try {
      final result = await _getMarketCoins(
        const MarketPageParams(
          page: 1,
          perPage: ApiConfig.pageSize,
          forceRefresh: true,
        ),
      );

      state = result.fold(
        (failure) => state,
        (coins) => state.copyWith(
          status: HomeStatus.success,
          coins: coins,
          page: 1,
          hasReachedEnd: coins.length < ApiConfig.pageSize,
          isLoadingMore: false,
          clearFailure: true,
        ),
      );
    } finally {
      state = state.copyWith(isRefreshing: false);
    }
  }

  Future<void> loadMore() async {
    if (state.isLoadingMore ||
        state.hasReachedEnd ||
        state.status != HomeStatus.success ||
        state.page >= PerformanceConfig.maxMarketPages) {
      return;
    }

    final nextPage = state.page + 1;
    state = state.copyWith(isLoadingMore: true);

    final result = await _getMarketCoins(
      MarketPageParams(page: nextPage, perPage: ApiConfig.pageSize),
    );

    state = result.fold((failure) => state.copyWith(isLoadingMore: false), (
      coins,
    ) {
      if (state.page + 1 != nextPage) {
        return state.copyWith(isLoadingMore: false);
      }
      if (coins.isEmpty) {
        return state.copyWith(isLoadingMore: false, hasReachedEnd: true);
      }
      return state.copyWith(
        coins: [...state.coins, ...coins],
        page: nextPage,
        isLoadingMore: false,
        hasReachedEnd:
            coins.length < ApiConfig.pageSize ||
            nextPage >= PerformanceConfig.maxMarketPages,
      );
    });
  }
}

final homeViewModelProvider = NotifierProvider<HomeViewModel, HomeState>(
  HomeViewModel.new,
);
