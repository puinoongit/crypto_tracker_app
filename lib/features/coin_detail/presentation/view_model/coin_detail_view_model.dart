import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:crypto_tracker_app/features/coin_detail/domain/usecase/get_coin_detail.dart';
import 'package:crypto_tracker_app/features/coin_detail/presentation/coin_detail_providers.dart';
import 'package:crypto_tracker_app/features/coin_detail/presentation/state/coin_detail_state.dart';

/// Per-coin detail ViewModel.
///
/// Implemented as a `family` so each coin gets its own isolated, cached state —
/// navigating between coins doesn't clobber another coin's data, and Riverpod
/// auto-disposes it when the screen is gone.
///
/// When a cached detail exists (even past TTL), it is shown immediately while
/// a background fetch runs — so a transient 429 does not blank the screen.
class CoinDetailViewModel
    extends AutoDisposeFamilyNotifier<CoinDetailState, String> {
  late final GetCoinDetail _getCoinDetail;

  @override
  CoinDetailState build(String coinId) {
    _getCoinDetail = ref.read(getCoinDetailUseCaseProvider);
    final cached = _getCoinDetail.peekCached(coinId);
    Future.microtask(load);
    if (cached != null) {
      return CoinDetailState(status: CoinDetailStatus.success, detail: cached);
    }
    return const CoinDetailState();
  }

  Future<void> load({bool forceRefresh = false}) async {
    final showingStale =
        state.status == CoinDetailStatus.success && state.detail != null;
    if (!showingStale || forceRefresh) {
      state = state.copyWith(
        status: showingStale
            ? CoinDetailStatus.success
            : CoinDetailStatus.loading,
        clearFailure: true,
      );
    }

    final result = await _getCoinDetail(
      CoinDetailParams(coinId: arg, forceRefresh: forceRefresh),
    );

    state = result.fold(
      (failure) {
        if (state.detail != null) {
          // Keep stale content visible; only surface error when we have nothing.
          return state;
        }
        return state.copyWith(status: CoinDetailStatus.error, failure: failure);
      },
      (detail) => state.copyWith(
        status: CoinDetailStatus.success,
        detail: detail,
        clearFailure: true,
      ),
    );
  }

  Future<void> refresh() async {
    if (state.status != CoinDetailStatus.success) {
      return load(forceRefresh: true);
    }
    if (state.isRefreshing) return;

    state = state.copyWith(isRefreshing: true, clearFailure: true);
    try {
      final result = await _getCoinDetail(
        CoinDetailParams(coinId: arg, forceRefresh: true),
      );

      state = result.fold(
        (failure) => state,
        (detail) => state.copyWith(detail: detail, clearFailure: true),
      );
    } finally {
      state = state.copyWith(isRefreshing: false);
    }
  }
}

final coinDetailViewModelProvider = NotifierProvider.autoDispose
    .family<CoinDetailViewModel, CoinDetailState, String>(
      CoinDetailViewModel.new,
    );
