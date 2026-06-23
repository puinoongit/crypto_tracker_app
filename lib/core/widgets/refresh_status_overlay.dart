import 'package:flutter/material.dart';

import 'refresh_status_banner.dart';

/// Tint + status pill shown while an explicit pull-to-refresh is running.
class RefreshStatusOverlay extends StatelessWidget {
  const RefreshStatusOverlay({
    required this.isRefreshing,
    required this.child,
    super.key,
  });

  final bool isRefreshing;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Stack(
      fit: StackFit.expand,
      clipBehavior: Clip.none,
      children: [
        child,
        Positioned.fill(
          child: IgnorePointer(
            child: AnimatedOpacity(
              opacity: isRefreshing ? 0.05 : 0,
              duration: const Duration(milliseconds: 220),
              child: ColoredBox(color: scheme.primary),
            ),
          ),
        ),
        Positioned(
          top: 10,
          left: 0,
          right: 0,
          child: SafeArea(
            bottom: false,
            child: Align(
              alignment: Alignment.topCenter,
              child: RefreshStatusBanner(visible: isRefreshing),
            ),
          ),
        ),
      ],
    );
  }
}
