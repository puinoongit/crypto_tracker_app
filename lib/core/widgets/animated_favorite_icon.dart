import 'package:flutter/material.dart';

/// A favorite (star) icon that "pops" with an elastic scale whenever its state
/// flips — a small, satisfying micro-interaction on tap.
class AnimatedFavoriteIcon extends StatelessWidget {
  const AnimatedFavoriteIcon({
    required this.isFavorite,
    this.inactiveColor,
    super.key,
  });

  final bool isFavorite;
  final Color? inactiveColor;

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 320),
      transitionBuilder: (child, animation) => ScaleTransition(
        scale: CurvedAnimation(parent: animation, curve: Curves.elasticOut),
        child: child,
      ),
      child: Icon(
        isFavorite ? Icons.star_rounded : Icons.star_border_rounded,
        key: ValueKey(isFavorite),
        color: isFavorite ? Colors.amber : inactiveColor,
      ),
    );
  }
}
