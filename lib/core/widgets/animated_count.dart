import 'package:flutter/material.dart';

/// Animates a numeric value by "counting" from its previous value to the new
/// one, rendering each frame through [formatter]. Used for the headline coin
/// price and the global market-cap card — the fintech "balance ticking up" feel.
class AnimatedCount extends StatelessWidget {
  const AnimatedCount({
    required this.value,
    required this.formatter,
    this.style,
    this.duration = const Duration(milliseconds: 650),
    super.key,
  });

  final double value;
  final String Function(double) formatter;
  final TextStyle? style;
  final Duration duration;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0, end: value),
      duration: duration,
      curve: Curves.easeOutCubic,
      builder: (context, animatedValue, _) => Text(
        formatter(animatedValue),
        style: style,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}
