import 'dart:ui';

import 'package:flutter/material.dart';

import 'package:crypto_tracker_app/core/localization/generated/app_localizations.dart';
import 'package:crypto_tracker_app/core/theme/app_theme.dart';

/// Floating fintech-style status pill shown while a refresh is in flight.
class RefreshStatusBanner extends StatefulWidget {
  const RefreshStatusBanner({required this.visible, super.key});

  final bool visible;

  @override
  State<RefreshStatusBanner> createState() => _RefreshStatusBannerState();
}

class _RefreshStatusBannerState extends State<RefreshStatusBanner>
    with TickerProviderStateMixin {
  late final AnimationController _pulseController = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1400),
  );
  late final AnimationController _shimmerController = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1800),
  );

  @override
  void initState() {
    super.initState();
    _syncAnimations();
  }

  @override
  void didUpdateWidget(covariant RefreshStatusBanner oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.visible != widget.visible) {
      _syncAnimations();
    }
  }

  void _syncAnimations() {
    if (widget.visible) {
      _pulseController.repeat();
      _shimmerController.repeat();
    } else {
      _pulseController.stop();
      _shimmerController.stop();
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _shimmerController.dispose();
    super.dispose();
  }

  String _label(AppLocalizations l10n, Locale locale) {
    final text = l10n.refreshUpdating;
    return locale.languageCode == 'en' ? text.toUpperCase() : text;
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.visible) return const SizedBox.shrink();

    final l10n = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context);
    final scheme = Theme.of(context).colorScheme;
    final theme = Theme.of(context);

    return IgnorePointer(
      child: ClipRRect(
        borderRadius: BorderRadius.circular(999),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
          child: DecoratedBox(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(999),
              color: scheme.surface.withValues(alpha: 0.78),
              border: Border.all(color: scheme.primary.withValues(alpha: 0.18)),
              boxShadow: [
                BoxShadow(
                  color: scheme.primary.withValues(alpha: 0.12),
                  blurRadius: 28,
                  offset: const Offset(0, 10),
                ),
                BoxShadow(
                  color: scheme.shadow.withValues(alpha: 0.06),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(14, 10, 16, 10),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _PulsingDots(
                    animation: _pulseController,
                    color: scheme.primary,
                    active: true,
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        _label(l10n, locale),
                        style: theme.textTheme.labelMedium?.copyWith(
                          color: scheme.onSurface,
                          fontWeight: FontWeight.w700,
                          letterSpacing: locale.languageCode == 'en'
                              ? 1.1
                              : 0.2,
                          height: 1.1,
                        ),
                      ),
                      const SizedBox(height: 5),
                      SizedBox(
                        width: 132,
                        height: 2,
                        child: AnimatedBuilder(
                          animation: _shimmerController,
                          builder: (context, _) {
                            return CustomPaint(
                              painter: _ShimmerTrackPainter(
                                progress: _shimmerController.value,
                                track: scheme.surfaceContainerHighest,
                                highlight: scheme.primary,
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 10),
                  Icon(Icons.bolt_rounded, size: 16, color: scheme.positive),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _PulsingDots extends StatelessWidget {
  const _PulsingDots({
    required this.animation,
    required this.color,
    required this.active,
  });

  final Animation<double> animation;
  final Color color;
  final bool active;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, _) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(3, (index) {
            final phase = (animation.value + index * 0.22) % 1.0;
            final scale = active
                ? 0.55 + (Curves.easeInOut.transform(phase) * 0.45)
                : 0.7;
            final opacity = active
                ? 0.35 + (Curves.easeInOut.transform(phase) * 0.65)
                : 0.5;

            return Padding(
              padding: EdgeInsets.only(right: index == 2 ? 0 : 4),
              child: Transform.scale(
                scale: scale,
                child: Container(
                  width: 6,
                  height: 6,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: color.withValues(alpha: opacity),
                    boxShadow: active
                        ? [
                            BoxShadow(
                              color: color.withValues(alpha: opacity * 0.45),
                              blurRadius: 6,
                            ),
                          ]
                        : null,
                  ),
                ),
              ),
            );
          }),
        );
      },
    );
  }
}

class _ShimmerTrackPainter extends CustomPainter {
  const _ShimmerTrackPainter({
    required this.progress,
    required this.track,
    required this.highlight,
  });

  final double progress;
  final Color track;
  final Color highlight;

  @override
  void paint(Canvas canvas, Size size) {
    final trackPaint = Paint()..color = track;
    final radius = Radius.circular(size.height / 2);
    canvas.drawRRect(
      RRect.fromRectAndRadius(Offset.zero & size, radius),
      trackPaint,
    );

    final highlightWidth = size.width * 0.42;
    final dx = (size.width + highlightWidth) * progress - highlightWidth;
    final gradient = LinearGradient(
      colors: [
        highlight.withValues(alpha: 0),
        highlight.withValues(alpha: 0.85),
        highlight.withValues(alpha: 0),
      ],
      stops: const [0, 0.5, 1],
    );

    canvas.save();
    canvas.clipRRect(RRect.fromRectAndRadius(Offset.zero & size, radius));
    canvas.drawRect(
      Rect.fromLTWH(dx, 0, highlightWidth, size.height),
      Paint()
        ..shader = gradient.createShader(
          Rect.fromLTWH(dx, 0, highlightWidth, size.height),
        ),
    );
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _ShimmerTrackPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
