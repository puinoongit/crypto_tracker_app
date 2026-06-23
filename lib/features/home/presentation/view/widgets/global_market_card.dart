import 'package:flutter/material.dart';

import 'package:crypto_tracker_app/core/localization/generated/app_localizations.dart';
import 'package:crypto_tracker_app/core/theme/app_theme.dart';
import 'package:crypto_tracker_app/core/utils/formatters.dart';
import 'package:crypto_tracker_app/core/widgets/animated_count.dart';
import 'package:crypto_tracker_app/features/home/domain/entity/global_market.dart';

/// Header summary card: total market cap (+24h change) and total 24h volume.
class GlobalMarketCard extends StatelessWidget {
  const GlobalMarketCard({required this.global, super.key});

  final GlobalMarket global;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final scheme = theme.colorScheme;
    final changeColor = global.isMarketUp ? scheme.positive : scheme.negative;

    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppTheme.cardRadius),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: scheme.heroGradient,
        ),
        border: Border.all(color: scheme.primary.withValues(alpha: 0.25)),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(18, 18, 18, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.insights_rounded, size: 18, color: scheme.primary),
                const SizedBox(width: 8),
                Text(
                  l10n.overviewGlobalTitle,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: scheme.primary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: _Metric(
                    label: l10n.overviewMarketCapLabel,
                    value: AnimatedCount(
                      value: global.totalMarketCap,
                      formatter: Formatters.compactCurrency,
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    trailing: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: changeColor.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        Formatters.percentage(
                          global.marketCapChangePercentage24h,
                        ),
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: changeColor,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _Metric(
                    label: l10n.overviewVolumeLabel,
                    value: AnimatedCount(
                      value: global.totalVolume,
                      formatter: Formatters.compactCurrency,
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _Metric extends StatelessWidget {
  const _Metric({required this.label, required this.value, this.trailing});

  final String label;
  final Widget value;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label.toUpperCase(),
          style: theme.textTheme.labelSmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Flexible(child: value),
            if (trailing != null) ...[const SizedBox(width: 8), trailing!],
          ],
        ),
      ],
    );
  }
}
