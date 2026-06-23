import 'package:flutter/material.dart';

/// A one-shot entrance animation: fades in while sliding up slightly.
///
/// Pass an increasing [delay] (e.g. per list index) to stagger a group of
/// children. The delay is implemented via an [Interval] on a single controller
/// rather than a `Timer`, so it composes cleanly and leaves no pending timers.
class FadeSlideIn extends StatefulWidget {
  const FadeSlideIn({
    required this.child,
    this.delay = Duration.zero,
    this.duration = const Duration(milliseconds: 350),
    super.key,
  });

  final Widget child;
  final Duration delay;
  final Duration duration;

  @override
  State<FadeSlideIn> createState() => _FadeSlideInState();
}

class _FadeSlideInState extends State<FadeSlideIn>
    with SingleTickerProviderStateMixin {
  late final Duration _total = widget.delay + widget.duration;

  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: _total,
  )..forward();

  late final Animation<double> _animation = CurvedAnimation(
    parent: _controller,
    curve: Interval(
      _total.inMicroseconds == 0
          ? 0.0
          : widget.delay.inMicroseconds / _total.inMicroseconds,
      1.0,
      curve: Curves.easeOutCubic,
    ),
  );

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _animation,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, 0.08),
          end: Offset.zero,
        ).animate(_animation),
        child: widget.child,
      ),
    );
  }
}
