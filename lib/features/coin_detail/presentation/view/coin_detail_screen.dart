import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:crypto_tracker_app/core/localization/generated/app_localizations.dart';
import 'package:crypto_tracker_app/core/navigation/hero_tags.dart';
import 'package:crypto_tracker_app/core/theme/app_theme.dart';
import 'package:crypto_tracker_app/core/utils/formatters.dart';
import 'package:crypto_tracker_app/core/utils/text_utils.dart';
import 'package:crypto_tracker_app/core/widgets/pull_to_refresh_sliver_scroll.dart';
import 'package:crypto_tracker_app/core/widgets/animated_count.dart';
import 'package:crypto_tracker_app/core/widgets/animated_favorite_icon.dart';
import 'package:crypto_tracker_app/core/widgets/coin_avatar.dart';
import 'package:crypto_tracker_app/core/widgets/error_view.dart';
import 'package:crypto_tracker_app/core/widgets/offline_banner.dart';
import 'package:crypto_tracker_app/features/favorites/presentation/view_model/favorites_controller.dart';
import 'package:crypto_tracker_app/features/coin_detail/domain/entity/coin_detail.dart';
import 'package:crypto_tracker_app/features/coin_detail/presentation/state/coin_detail_state.dart';
import 'package:crypto_tracker_app/features/coin_detail/presentation/view_model/coin_detail_view_model.dart';
import 'package:crypto_tracker_app/features/home/presentation/market_visibility_providers.dart';
import 'widgets/coin_detail_skeleton.dart';
import 'widgets/stat_tile.dart';

/// Detail screen for a single coin, pushed from the market/favorites lists.
class CoinDetailScreen extends ConsumerStatefulWidget {
  const CoinDetailScreen({
    required this.coinId,
    required this.fallbackName,
    super.key,
  });

  final String coinId;
  final String fallbackName;

  @override
  ConsumerState<CoinDetailScreen> createState() => _CoinDetailScreenState();
}

class _CoinDetailScreenState extends ConsumerState<CoinDetailScreen> {
  ProviderContainer? _container;
  bool _detailRegistered = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _container ??= ProviderScope.containerOf(context, listen: false);
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _container
          ?.read(detailScreenOpenCountProvider.notifier)
          .update((c) => c + 1);
      _detailRegistered = true;
    });
  }

  @override
  void dispose() {
    if (_detailRegistered) {
      final container = _container;
      Future.microtask(() {
        try {
          container
              ?.read(detailScreenOpenCountProvider.notifier)
              .update((c) => c > 0 ? c - 1 : 0);
        } on StateError {
          // ProviderScope already torn down (e.g. widget tests).
        }
      });
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final state = ref.watch(coinDetailViewModelProvider(widget.coinId));
    final detail = state.detail;
    final title = detail != null
        ? '${detail.symbol.toUpperCase()} · ${l10n.coinDetailRankShort(detail.marketCapRank)}'
        : (widget.fallbackName.isEmpty ? widget.coinId : widget.fallbackName);

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(title),
        actions: [
          if (state.detail != null) _FavoriteAction(detail: state.detail!),
        ],
      ),
      body: Column(
        children: [
          const OfflineBanner(),
          Expanded(
            child: _DetailBody(coinId: widget.coinId, state: state),
          ),
        ],
      ),
    );
  }
}

class _FavoriteAction extends ConsumerWidget {
  const _FavoriteAction({required this.detail});

  final CoinDetail detail;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final isFavorite = ref.watch(isFavoriteProvider(detail.id));

    return IconButton(
      tooltip: isFavorite ? l10n.removeFromFavorites : l10n.addToFavorites,
      icon: AnimatedFavoriteIcon(isFavorite: isFavorite),
      onPressed: () =>
          ref.read(favoritesControllerProvider.notifier).toggle(detail.id),
    );
  }
}

class _DetailBody extends ConsumerWidget {
  const _DetailBody({required this.coinId, required this.state});

  final String coinId;
  final CoinDetailState state;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    switch (state.status) {
      case CoinDetailStatus.loading:
        return const CoinDetailSkeleton();

      case CoinDetailStatus.error:
        return ErrorView(
          failure: state.failure!,
          onRetry: () =>
              ref.read(coinDetailViewModelProvider(coinId).notifier).load(),
        );

      case CoinDetailStatus.success:
        return _DetailContent(detail: state.detail!, coinId: coinId);
    }
  }
}

class _DetailContent extends ConsumerWidget {
  const _DetailContent({required this.detail, required this.coinId});

  final CoinDetail detail;
  final String coinId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final changeColor = detail.isPriceUp
        ? theme.colorScheme.positive
        : theme.colorScheme.negative;
    final description = TextUtils.stripHtml(detail.description);
    final isRefreshing = ref.watch(
      coinDetailViewModelProvider(coinId).select((s) => s.isRefreshing),
    );

    return PullToRefreshSliverScroll(
      isRefreshing: isRefreshing,
      onRefresh: () =>
          ref.read(coinDetailViewModelProvider(coinId).notifier).refresh(),
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.all(16),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              Row(
                children: [
                  Hero(
                    tag: coinAvatarHeroTag(detail.id),
                    child: CoinAvatar(imageUrl: detail.imageUrl, size: 56),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(detail.name, style: theme.textTheme.titleLarge),
                        Text(
                          detail.symbol.toUpperCase(),
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              AnimatedCount(
                value: detail.currentPrice,
                formatter: Formatters.price,
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Icon(
                    detail.isPriceUp
                        ? Icons.arrow_drop_up_rounded
                        : Icons.arrow_drop_down_rounded,
                    color: changeColor,
                  ),
                  Text(
                    '${Formatters.percentage(detail.priceChangePercentage24h)} (24h)',
                    style: theme.textTheme.titleSmall?.copyWith(
                      color: changeColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                // Give tiles enough height for label, value, and optional delta text.
                childAspectRatio: 1.9,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                children: [
                  StatTile(
                    label: l10n.coinDetailMarketCap,
                    value: Formatters.compactCurrency(detail.marketCap),
                  ),
                  StatTile(
                    label: l10n.coinDetailVolume,
                    value: Formatters.compactCurrency(detail.totalVolume),
                  ),
                  StatTile(
                    label: l10n.coinDetailAth,
                    value: Formatters.price(detail.ath),
                    subValue: Formatters.percentage(detail.athChangePercentage),
                    subValueColor: detail.athChangePercentage >= 0
                        ? theme.colorScheme.positive
                        : theme.colorScheme.negative,
                  ),
                  StatTile(
                    label: l10n.coinDetailAtl,
                    value: Formatters.price(detail.atl),
                    subValue: Formatters.percentage(detail.atlChangePercentage),
                    subValueColor: detail.atlChangePercentage >= 0
                        ? theme.colorScheme.positive
                        : theme.colorScheme.negative,
                  ),
                  StatTile(
                    label: l10n.coinDetailSupply,
                    value:
                        '${Formatters.compact(detail.circulatingSupply)} ${detail.symbol.toUpperCase()}',
                  ),
                  StatTile(
                    label: l10n.coinDetailMaxSupply,
                    value: detail.maxSupply == null
                        ? l10n.maxSupplyUncapped
                        : '${Formatters.compact(detail.maxSupply)} ${detail.symbol.toUpperCase()}',
                  ),
                ],
              ),
              if (description.isNotEmpty) ...[
                const SizedBox(height: 24),
                Text(
                  l10n.coinDetailAbout(detail.name),
                  style: theme.textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                Text(
                  description,
                  style: theme.textTheme.bodyMedium?.copyWith(height: 1.5),
                ),
              ],
            ]),
          ),
        ),
      ],
    );
  }
}
