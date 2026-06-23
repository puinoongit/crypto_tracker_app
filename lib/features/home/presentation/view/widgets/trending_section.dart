import 'package:flutter/material.dart';

import 'package:crypto_tracker_app/core/localization/generated/app_localizations.dart';
import 'package:crypto_tracker_app/core/navigation/page_transitions.dart';
import 'package:crypto_tracker_app/core/theme/app_theme.dart';
import 'package:crypto_tracker_app/core/utils/formatters.dart';
import 'package:crypto_tracker_app/core/widgets/coin_avatar.dart';
import 'package:crypto_tracker_app/core/widgets/trending_sparkline.dart';
import 'package:crypto_tracker_app/features/coin_detail/presentation/view/coin_detail_screen.dart';
import 'package:crypto_tracker_app/features/home/domain/entity/trending_coin.dart';

/// Horizontal "Trending · 24h" carousel shown in the markets header.
class TrendingSection extends StatelessWidget {
  const TrendingSection({required this.coins, super.key});

  final List<TrendingCoin> coins;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
          child: Row(
            children: [
              Icon(
                Icons.local_fire_department_rounded,
                size: 16,
                color: theme.colorScheme.primary,
              ),
              const SizedBox(width: 6),
              Text(
                '${l10n.overviewTrending} · 24h'.toUpperCase(),
                style: theme.textTheme.labelSmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 104,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: coins.length,
            separatorBuilder: (_, _) => const SizedBox(width: 12),
            itemBuilder: (context, index) => _TrendingCard(coin: coins[index]),
          ),
        ),
      ],
    );
  }
}

class _TrendingCard extends StatelessWidget {
  const _TrendingCard({required this.coin});

  final TrendingCoin coin;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final changeColor = coin.isPriceUp
        ? theme.colorScheme.positive
        : theme.colorScheme.negative;

    return InkWell(
      borderRadius: BorderRadius.circular(AppTheme.cardRadius),
      onTap: () => Navigator.of(context).push(
        fadeThroughRoute(
          CoinDetailScreen(coinId: coin.id, fallbackName: coin.name),
        ),
      ),
      child: Ink(
        width: 164,
        padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerHighest.withValues(
            alpha: 0.4,
          ),
          borderRadius: BorderRadius.circular(AppTheme.cardRadius),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CoinAvatar(imageUrl: coin.thumb, size: 26),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        coin.symbol.toUpperCase(),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.titleSmall,
                      ),
                      if (coin.marketCapRank > 0)
                        Text(
                          '#${coin.marketCapRank}',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                            fontSize: 11,
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
            const Spacer(),
            if (coin.hasSparkline) ...[
              TrendingSparkline(url: coin.sparklineUrl, color: changeColor),
              const SizedBox(height: 6),
            ],
            Text(
              Formatters.percentage(coin.priceChangePercentage24h),
              style: theme.textTheme.labelSmall?.copyWith(
                color: changeColor,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
