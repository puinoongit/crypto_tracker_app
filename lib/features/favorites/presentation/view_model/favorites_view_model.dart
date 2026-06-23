import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:crypto_tracker_app/features/favorites/presentation/state/favorites_state.dart';
import 'package:crypto_tracker_app/features/favorites/presentation/view_model/favorites_controller.dart';
import 'package:crypto_tracker_app/features/home/domain/entity/coin.dart';
import 'package:crypto_tracker_app/features/home/domain/usecase/get_market_coins_by_ids.dart';
import 'package:crypto_tracker_app/features/home/presentation/home_providers.dart';
import 'package:crypto_tracker_app/features/home/presentation/view_model/home_view_model.dart';

/// Loads favorite coins from the market API when the tab opens or ids change.
class FavoritesViewModel extends Notifier<FavoritesState> {
  late final GetMarketCoinsByIds _getMarketCoinsByIds;

  @override
  FavoritesState build() {
    _getMarketCoinsByIds = ref.watch(getMarketCoinsByIdsUseCaseProvider);

    ref.listen(favoritesControllerProvider, (previous, next) {
      if (previous != next) {
        load(favoriteIds: next);
      }
    });

    Future.microtask(
      () => load(favoriteIds: ref.read(favoritesControllerProvider)),
    );
    return const FavoritesState();
  }

  Future<void> load({
    List<String>? favoriteIds,
    bool forceRefresh = false,
  }) async {
    final coinIds =
        favoriteIds ?? ref.read(favoritesControllerProvider) ?? const [];
    if (coinIds.isEmpty) {
      state = const FavoritesState(status: FavoritesStatus.success);
      return;
    }

    if (!forceRefresh || state.coins.isEmpty) {
      state = state.copyWith(
        status: FavoritesStatus.loading,
        clearFailure: true,
      );
    } else {
      state = state.copyWith(isRefreshing: true, clearFailure: true);
    }

    try {
      final result = await _getMarketCoinsByIds(
        MarketCoinsByIdsParams(ids: coinIds, forceRefresh: forceRefresh),
      );

      state = result.fold(
        (failure) =>
            state.copyWith(status: FavoritesStatus.error, failure: failure),
        (coins) => state.copyWith(
          status: FavoritesStatus.success,
          coins: coins,
          clearFailure: true,
        ),
      );
    } finally {
      if (state.isRefreshing) {
        state = state.copyWith(isRefreshing: false);
      }
    }
  }

  Future<void> refresh() => load(forceRefresh: true);
}

final favoritesViewModelProvider =
    NotifierProvider<FavoritesViewModel, FavoritesState>(
      FavoritesViewModel.new,
    );

/// Overlays market-list prices onto favorites when the same coin is already
/// loaded on the Market tab, keeping both tabs in sync.
List<Coin> mergeFavoriteCoinsWithMarket({
  required List<Coin> favorites,
  required List<Coin> market,
}) {
  if (favorites.isEmpty || market.isEmpty) return favorites;

  final marketById = {for (final coin in market) coin.id: coin};
  return [for (final coin in favorites) marketById[coin.id] ?? coin];
}

/// Coins rendered on the Favorites tab (market prices win when available).
final favoriteDisplayCoinsProvider = Provider<List<Coin>>((ref) {
  final favorites = ref.watch(favoritesViewModelProvider).coins;
  final market = ref.watch(homeViewModelProvider).coins;
  return mergeFavoriteCoinsWithMarket(favorites: favorites, market: market);
});
