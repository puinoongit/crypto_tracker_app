import 'package:flutter/material.dart';

import 'package:crypto_tracker_app/core/widgets/shimmer.dart';

/// Shimmering placeholder for the coin detail screen while it loads.
class CoinDetailSkeleton extends StatelessWidget {
  const CoinDetailSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer(
      child: ListView(
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        children: [
          const Row(
            children: [
              ShimmerBox(width: 56, height: 56, shape: BoxShape.circle),
              SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ShimmerBox(width: 140, height: 16),
                  SizedBox(height: 8),
                  ShimmerBox(width: 60, height: 12),
                ],
              ),
            ],
          ),
          const SizedBox(height: 28),
          const ShimmerBox(width: 180, height: 30),
          const SizedBox(height: 10),
          const ShimmerBox(width: 110, height: 16),
          const SizedBox(height: 28),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            childAspectRatio: 1.9,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            children: List.generate(
              6,
              (_) => const ShimmerBox(width: double.infinity, height: 64),
            ),
          ),
        ],
      ),
    );
  }
}
