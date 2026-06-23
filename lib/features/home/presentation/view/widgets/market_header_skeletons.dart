import 'package:flutter/material.dart';

import 'package:crypto_tracker_app/core/theme/app_theme.dart';
import 'package:crypto_tracker_app/core/widgets/shimmer.dart';

/// Shimmer placeholder for [GlobalMarketCard] while global stats load.
class GlobalMarketCardSkeleton extends StatelessWidget {
  const GlobalMarketCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: Shimmer(
        child: DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppTheme.cardRadius),
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
          ),
          child: const Padding(
            padding: EdgeInsets.fromLTRB(18, 18, 18, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ShimmerBox(width: 140, height: 12),
                SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ShimmerBox(width: 90, height: 10),
                          SizedBox(height: 8),
                          ShimmerBox(width: 120, height: 18),
                        ],
                      ),
                    ),
                    SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ShimmerBox(width: 90, height: 10),
                          SizedBox(height: 8),
                          ShimmerBox(width: 100, height: 18),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Shimmer placeholder for [TrendingSection] while trending coins load.
class TrendingSectionSkeleton extends StatelessWidget {
  const TrendingSectionSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Shimmer(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(16, 4, 16, 8),
              child: ShimmerBox(width: 120, height: 10),
            ),
            SizedBox(
              height: 104,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                physics: const NeverScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: 3,
                separatorBuilder: (_, _) => const SizedBox(width: 10),
                itemBuilder: (_, _) =>
                    const ShimmerBox(width: 132, height: 104, radius: 14),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
