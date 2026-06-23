import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:crypto_tracker_app/core/localization/generated/app_localizations.dart';
import 'package:crypto_tracker_app/core/navigation/hero_tags.dart';
import 'package:crypto_tracker_app/core/navigation/page_transitions.dart';
import 'package:crypto_tracker_app/core/theme/app_theme.dart';
import 'package:crypto_tracker_app/core/utils/formatters.dart';
import 'package:crypto_tracker_app/core/widgets/animated_favorite_icon.dart';
import 'package:crypto_tracker_app/core/widgets/coin_avatar.dart';
import 'package:crypto_tracker_app/core/widgets/sparkline_chart.dart';
import 'package:crypto_tracker_app/features/coin_detail/presentation/view/coin_detail_screen.dart';
import 'package:crypto_tracker_app/features/favorites/presentation/view_model/favorites_controller.dart';
import 'package:crypto_tracker_app/features/home/domain/entity/coin.dart';

/// A single market-list row with rank badge and wide sparkline.
class CoinListItem extends StatelessWidget {
  const CoinListItem({required this.coin, this.enableHero = false, super.key});

  final Coin coin;
  final bool enableHero;

  void _openDetail(BuildContext context) {
    Navigator.of(context).push(
      fadeThroughRoute(
        CoinDetailScreen(coinId: coin.id, fallbackName: coin.name),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final changeColor = coin.isPriceUp ? scheme.positive : scheme.negative;
    final showSparkline = coin.sparklinePrices.length >= 2;

    Widget avatar = CoinAvatar(imageUrl: coin.imageUrl);
    if (enableHero) {
      avatar = Hero(tag: coinAvatarHeroTag(coin.id), child: avatar);
    }

    return RepaintBoundary(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _openDetail(context),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Row(
              children: [
                _RankBadge(rank: coin.marketCapRank),
                const SizedBox(width: 10),
                avatar,
                const SizedBox(width: 12),
                Expanded(
                  flex: showSparkline ? 3 : 4,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        coin.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.titleSmall,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        coin.symbol.toUpperCase(),
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: scheme.onSurfaceVariant,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.8,
                        ),
                      ),
                    ],
                  ),
                ),
                if (showSparkline) ...[
                  const SizedBox(width: 8),
                  Expanded(
                    flex: 2,
                    child: SparklineChart(
                      prices: coin.sparklinePrices,
                      color: changeColor,
                    ),
                  ),
                ],
                const SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      Formatters.price(coin.currentPrice),
                      style: theme.textTheme.titleSmall,
                    ),
                    const SizedBox(height: 2),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: changeColor.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        Formatters.percentage(coin.priceChangePercentage24h),
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: changeColor,
                        ),
                      ),
                    ),
                  ],
                ),
                _FavoriteToggle(coinId: coin.id),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _FavoriteToggle extends ConsumerWidget {
  const _FavoriteToggle({required this.coinId});

  final String coinId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    final isFavorite = ref.watch(isFavoriteProvider(coinId));

    return IconButton(
      onPressed: () =>
          ref.read(favoritesControllerProvider.notifier).toggle(coinId),
      icon: AnimatedFavoriteIcon(
        isFavorite: isFavorite,
        inactiveColor: scheme.outline,
      ),
      tooltip: isFavorite ? l10n.removeFromFavorites : l10n.addToFavorites,
    );
  }
}

class _RankBadge extends StatelessWidget {
  const _RankBadge({required this.rank});

  final int rank;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return SizedBox(
      width: 28,
      child: Text(
        '#$rank',
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          color: scheme.onSurfaceVariant.withValues(alpha: 0.8),
          fontFeatures: const [FontFeature.tabularFigures()],
        ),
      ),
    );
  }
}
