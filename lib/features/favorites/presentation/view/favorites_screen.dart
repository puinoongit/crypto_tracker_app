import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:crypto_tracker_app/core/localization/generated/app_localizations.dart';
import 'package:crypto_tracker_app/core/widgets/empty_view.dart';
import 'package:crypto_tracker_app/core/widgets/error_view.dart';
import 'package:crypto_tracker_app/core/widgets/pull_to_refresh_sliver_scroll.dart';
import 'package:crypto_tracker_app/core/config/performance_config.dart';
import 'package:crypto_tracker_app/features/favorites/presentation/state/favorites_state.dart';
import 'package:crypto_tracker_app/features/favorites/presentation/view_model/favorites_controller.dart';
import 'package:crypto_tracker_app/features/favorites/presentation/view_model/favorites_view_model.dart';
import 'package:crypto_tracker_app/features/home/presentation/view/widgets/coin_list_item.dart';
import 'package:crypto_tracker_app/features/home/presentation/view/widgets/market_list_skeleton.dart';

/// Favorites tab. Fetches price + sparkline from the market API when opened
/// and on pull-to-refresh, keyed only by stored favorite ids.
class FavoritesScreen extends ConsumerWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final favoriteIds = ref.watch(favoritesControllerProvider);
    final state = ref.watch(favoritesViewModelProvider);

    if (favoriteIds.isEmpty) {
      return EmptyView(
        icon: Icons.star_border_rounded,
        title: l10n.emptyFavoritesTitle,
        message: l10n.emptyFavoritesMessage,
      );
    }

    return switch (state.status) {
      FavoritesStatus.initial ||
      FavoritesStatus.loading => const MarketListSkeleton(),
      FavoritesStatus.error => ErrorView(
        failure: state.failure!,
        onRetry: () => ref.read(favoritesViewModelProvider.notifier).load(),
      ),
      FavoritesStatus.success => const _FavoritesList(),
    };
  }
}

class _FavoritesList extends ConsumerWidget {
  const _FavoritesList();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final displayCoins = ref.watch(favoriteDisplayCoinsProvider);
    final isRefreshing = ref.watch(
      favoritesViewModelProvider.select((s) => s.isRefreshing),
    );

    return PullToRefreshSliverScroll(
      isRefreshing: isRefreshing,
      onRefresh: () => ref.read(favoritesViewModelProvider.notifier).refresh(),
      scrollKey: const PageStorageKey<String>('favorites_coin_list'),
      scrollCacheExtent: PerformanceConfig.listCacheExtent,
      slivers: [
        SliverList.separated(
          itemCount: displayCoins.length,
          separatorBuilder: (_, _) => const Divider(height: 1, indent: 72),
          itemBuilder: (context, index) {
            final coin = displayCoins[index];
            return CoinListItem(key: ValueKey(coin.id), coin: coin);
          },
        ),
      ],
    );
  }
}
