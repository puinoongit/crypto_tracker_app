import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:crypto_tracker_app/features/home/domain/usecase/get_global_market.dart';
import 'package:crypto_tracker_app/features/home/domain/usecase/get_trending_coins.dart';
import 'package:crypto_tracker_app/features/home/presentation/home_providers.dart';
import 'package:crypto_tracker_app/features/home/presentation/state/home_state.dart';
import 'package:crypto_tracker_app/features/home/presentation/state/market_overview_state.dart';
import 'package:crypto_tracker_app/features/home/presentation/view_model/home_view_model.dart';

/// Loads the markets-overview header (global stats + trending coins), then
/// kicks off the paginated coin list.
///
/// Requests run sequentially (global → trending → list) to match the on-screen
/// journey and reduce CoinGecko burst traffic.
class MarketOverviewViewModel extends Notifier<MarketOverviewState> {
  late final GetGlobalMarket _getGlobalMarket;
  late final GetTrendingCoins _getTrendingCoins;

  @override
  MarketOverviewState build() {
    _getGlobalMarket = ref.watch(getGlobalMarketUseCaseProvider);
    _getTrendingCoins = ref.watch(getTrendingCoinsUseCaseProvider);
    Future.microtask(load);
    return const MarketOverviewState();
  }

  Future<void> load({bool forceRefresh = false}) async {
    final keepHeaderVisible =
        forceRefresh && state.phase == MarketOverviewPhase.complete;

    if (!keepHeaderVisible) {
      state = state.copyWith(
        phase: MarketOverviewPhase.loadingGlobal,
        isLoading: true,
      );
    } else {
      state = state.copyWith(isLoading: true);
    }

    final globalResult = await _getGlobalMarket(forceRefresh: forceRefresh);
    if (!ref.exists(marketOverviewViewModelProvider)) return;

    if (!keepHeaderVisible) {
      state = MarketOverviewState(
        global: globalResult.fold((_) => state.global, (v) => v),
        trending: state.trending,
        phase: MarketOverviewPhase.loadingTrending,
      );
    } else {
      state = state.copyWith(
        global: globalResult.fold((_) => state.global, (v) => v),
        isLoading: true,
      );
    }

    final trendingResult = await _getTrendingCoins(forceRefresh: forceRefresh);
    if (!ref.exists(marketOverviewViewModelProvider)) return;

    state = MarketOverviewState(
      global: state.global,
      trending: trendingResult.fold((_) => state.trending, (v) => v),
      phase: MarketOverviewPhase.complete,
      isLoading: false,
    );

    final home = ref.read(homeViewModelProvider);
    if (home.status == HomeStatus.initial) {
      await ref.read(homeViewModelProvider.notifier).loadInitial();
    }
  }

  Future<void> refresh() => load(forceRefresh: true);
}

final marketOverviewViewModelProvider =
    NotifierProvider<MarketOverviewViewModel, MarketOverviewState>(
      MarketOverviewViewModel.new,
    );
