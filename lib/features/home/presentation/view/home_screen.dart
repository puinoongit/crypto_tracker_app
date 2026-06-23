import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:crypto_tracker_app/core/config/performance_config.dart';
import 'package:crypto_tracker_app/core/localization/generated/app_localizations.dart';
import 'package:crypto_tracker_app/core/widgets/empty_view.dart';
import 'package:crypto_tracker_app/core/widgets/error_view.dart';
import 'package:crypto_tracker_app/core/widgets/fade_slide_in.dart';
import 'package:crypto_tracker_app/core/widgets/pull_to_refresh_sliver_scroll.dart';
import 'package:crypto_tracker_app/core/widgets/refresh_status_overlay.dart';
import 'package:crypto_tracker_app/features/home/presentation/market_visibility_providers.dart';
import 'package:crypto_tracker_app/features/home/presentation/state/home_state.dart';
import 'package:crypto_tracker_app/features/home/presentation/state/market_overview_state.dart';
import 'package:crypto_tracker_app/features/home/presentation/view_model/home_view_model.dart';
import 'package:crypto_tracker_app/features/home/presentation/view_model/market_overview_view_model.dart';
import 'widgets/coin_list_item.dart';
import 'widgets/global_market_card.dart';
import 'widgets/market_header_skeletons.dart';
import 'widgets/market_list_skeleton.dart';
import 'widgets/trending_section.dart';

/// Market list tab: staged header load, then pull-to-refresh and infinite scroll.
class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen>
    with WidgetsBindingObserver {
  static const _loadMoreThreshold = 0.8;
  static const _minRefreshBannerDuration = Duration(milliseconds: 700);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(appInForegroundProvider.notifier).state = true;
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    ref.read(appInForegroundProvider.notifier).state =
        state == AppLifecycleState.resumed;
  }

  bool _loadMoreQueued = false;
  bool _pullRefreshing = false;

  bool _onScrollNotification(ScrollNotification notification) {
    if (notification.depth != 0) return false;
    if (notification is! ScrollUpdateNotification &&
        notification is! ScrollEndNotification) {
      return false;
    }

    final metrics = notification.metrics;
    if (metrics.maxScrollExtent <= 0) return false;
    if (metrics.pixels < metrics.maxScrollExtent * _loadMoreThreshold) {
      return false;
    }
    if (_loadMoreQueued) return false;

    _loadMoreQueued = true;
    ref.read(homeViewModelProvider.notifier).loadMore().whenComplete(() {
      if (mounted) _loadMoreQueued = false;
    });
    return false;
  }

  Future<void> _onPullRefresh() async {
    if (_pullRefreshing) return;
    setState(() => _pullRefreshing = true);
    await WidgetsBinding.instance.endOfFrame;

    final started = DateTime.now();
    try {
      await Future.wait([
        ref.read(homeViewModelProvider.notifier).refresh(),
        ref.read(marketOverviewViewModelProvider.notifier).refresh(),
      ]);
    } finally {
      final elapsed = DateTime.now().difference(started);
      final remaining = _minRefreshBannerDuration - elapsed;
      if (remaining > Duration.zero) {
        await Future<void>.delayed(remaining);
      }
      if (mounted) setState(() => _pullRefreshing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(homeViewModelProvider);
    final overview = ref.watch(marketOverviewViewModelProvider);
    final showRefreshBanner = _pullRefreshing || state.isRefreshing;

    return RefreshStatusOverlay(
      isRefreshing: showRefreshBanner,
      child: NotificationListener<ScrollNotification>(
        onNotification: _onScrollNotification,
        child: _HomeBody(
          state: state,
          overview: overview,
          onRefresh: _onPullRefresh,
        ),
      ),
    );
  }
}

class _MarketHeader extends StatelessWidget {
  const _MarketHeader({required this.overview});

  final MarketOverviewState overview;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (overview.hasGlobal)
          FadeSlideIn(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: GlobalMarketCard(global: overview.global!),
            ),
          )
        else if (overview.showGlobalSkeleton)
          const GlobalMarketCardSkeleton(),
        if (overview.hasTrending)
          FadeSlideIn(
            delay: const Duration(milliseconds: 80),
            child: Padding(
              padding: const EdgeInsets.only(top: 12),
              child: TrendingSection(coins: overview.trending),
            ),
          )
        else if (overview.showTrendingSkeleton)
          const TrendingSectionSkeleton(),
      ],
    );
  }
}

class _HomeBody extends ConsumerWidget {
  const _HomeBody({
    required this.state,
    required this.overview,
    required this.onRefresh,
  });

  final HomeState state;
  final MarketOverviewState overview;
  final Future<void> Function() onRefresh;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);

    if (!overview.isHeaderComplete) {
      return CustomScrollView(
        physics: pullToRefreshScrollPhysics,
        slivers: [SliverToBoxAdapter(child: _MarketHeader(overview: overview))],
      );
    }

    switch (state.status) {
      case HomeStatus.initial:
      case HomeStatus.loading:
        return CustomScrollView(
          physics: pullToRefreshScrollPhysics,
          slivers: [
            SliverToBoxAdapter(child: _MarketHeader(overview: overview)),
            const SliverFillRemaining(child: MarketListSkeleton()),
          ],
        );

      case HomeStatus.error:
        return PullToRefreshSliverScroll(
          showStatusOverlay: false,
          isRefreshing: false,
          onRefresh: onRefresh,
          slivers: [
            SliverToBoxAdapter(child: _MarketHeader(overview: overview)),
            SliverFillRemaining(
              child: ErrorView(
                failure: state.failure!,
                onRetry: () =>
                    ref.read(homeViewModelProvider.notifier).loadInitial(),
              ),
            ),
          ],
        );

      case HomeStatus.success:
        if (state.coins.isEmpty) {
          return PullToRefreshSliverScroll(
            showStatusOverlay: false,
            isRefreshing: false,
            onRefresh: onRefresh,
            slivers: [
              SliverToBoxAdapter(child: _MarketHeader(overview: overview)),
              SliverFillRemaining(
                child: EmptyView(
                  icon: Icons.inbox_rounded,
                  title: l10n.emptyMarketTitle,
                  message: l10n.emptyMarketMessage,
                ),
              ),
            ],
          );
        }

        return PullToRefreshSliverScroll(
          showStatusOverlay: false,
          isRefreshing: false,
          onRefresh: onRefresh,
          scrollKey: const PageStorageKey<String>('market_coin_list'),
          scrollCacheExtent: PerformanceConfig.listCacheExtent,
          slivers: [
            SliverToBoxAdapter(child: _MarketHeader(overview: overview)),
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  if (index < state.coins.length) {
                    final coin = state.coins[index];
                    return Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (index > 0) const Divider(height: 1, indent: 72),
                        CoinListItem(
                          key: ValueKey(coin.id),
                          coin: coin,
                          enableHero: true,
                        ),
                      ],
                    );
                  }
                  return _ListFooter(state: state);
                },
                childCount: state.coins.length + 1,
                addAutomaticKeepAlives: false,
              ),
            ),
          ],
        );
    }
  }
}

class _ListFooter extends StatelessWidget {
  const _ListFooter({required this.state});

  final HomeState state;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    if (state.isLoadingMore) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 20),
        child: Center(
          child: SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(strokeWidth: 2.5),
          ),
        ),
      );
    }

    if (state.hasReachedEnd && state.coins.isNotEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Center(
          child: Text(
            l10n.endOfListReached,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.outline,
            ),
          ),
        ),
      );
    }

    return const SizedBox(height: 8);
  }
}
