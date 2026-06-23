import 'package:flutter/material.dart';

/// Sweeps an animated gradient band across its (opaque) descendants to produce a
/// shimmer/skeleton loading effect. Wrap a group of [ShimmerBox]es in a single
/// [Shimmer] so they animate in unison.
///
/// Uses one repeating [AnimationController] + a `ShaderMask`, so the whole
/// skeleton is a single cheap repaint.
class Shimmer extends StatefulWidget {
  const Shimmer({required this.child, super.key});

  final Widget child;

  @override
  State<Shimmer> createState() => _ShimmerState();
}

class _ShimmerState extends State<Shimmer> with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1300),
  )..repeat();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final base = scheme.surfaceContainerHighest;
    final highlight = Color.lerp(base, scheme.onSurface, 0.10)!;

    return RepaintBoundary(
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return ShaderMask(
            blendMode: BlendMode.srcATop,
            shaderCallback: (bounds) {
              return LinearGradient(
                colors: [base, highlight, base],
                stops: const [0.25, 0.5, 0.75],
                transform: _SlidingGradient(_controller.value),
              ).createShader(bounds);
            },
            child: child,
          );
        },
        child: widget.child,
      ),
    );
  }
}

/// Translates the gradient horizontally from off-screen left to off-screen right.
class _SlidingGradient extends GradientTransform {
  const _SlidingGradient(this.value);

  final double value;

  @override
  Matrix4 transform(Rect bounds, {TextDirection? textDirection}) {
    final dx = bounds.width * (value * 3 - 1.5);
    return Matrix4.translationValues(dx, 0, 0);
  }
}

/// An opaque placeholder block painted by an enclosing [Shimmer].
class ShimmerBox extends StatelessWidget {
  const ShimmerBox({
    required this.width,
    required this.height,
    this.shape = BoxShape.rectangle,
    this.radius = 8,
    super.key,
  });

  final double width;
  final double height;
  final BoxShape shape;
  final double radius;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        shape: shape,
        borderRadius: shape == BoxShape.circle
            ? null
            : BorderRadius.circular(radius),
      ),
    );
  }
}
