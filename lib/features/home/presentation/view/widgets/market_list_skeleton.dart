import 'package:flutter/material.dart';

import 'package:crypto_tracker_app/core/widgets/shimmer.dart';

/// Shimmering placeholder for the market list while the first page loads.
class MarketListSkeleton extends StatelessWidget {
  const MarketListSkeleton({this.itemCount = 9, super.key});

  final int itemCount;

  @override
  Widget build(BuildContext context) {
    return Shimmer(
      child: ListView.builder(
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(vertical: 8),
        itemCount: itemCount,
        itemBuilder: (_, _) => const _SkeletonRow(),
      ),
    );
  }
}

class _SkeletonRow extends StatelessWidget {
  const _SkeletonRow();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          ShimmerBox(width: 40, height: 40, shape: BoxShape.circle),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ShimmerBox(width: 120, height: 12),
                SizedBox(height: 8),
                ShimmerBox(width: 80, height: 10),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              ShimmerBox(width: 70, height: 12),
              SizedBox(height: 8),
              ShimmerBox(width: 48, height: 10),
            ],
          ),
        ],
      ),
    );
  }
}
