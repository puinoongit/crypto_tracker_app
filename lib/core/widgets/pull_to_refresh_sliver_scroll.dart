import 'package:flutter/cupertino.dart';
import 'package:flutter/rendering.dart' show ScrollCacheExtent;

import 'refresh_status_overlay.dart';

/// Shared scroll physics so pull-to-refresh feels the same on Android and iOS.
const AlwaysScrollableScrollPhysics pullToRefreshScrollPhysics =
    AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics());

/// Scroll view with a sliver pull-to-refresh control.
///
/// [CupertinoSliverRefreshControl] only fires [onRefresh] after the user pulls
/// past the top edge and releases — scrolling back to the top does not fetch.
class PullToRefreshSliverScroll extends StatelessWidget {
  const PullToRefreshSliverScroll({
    required this.isRefreshing,
    required this.onRefresh,
    required this.slivers,
    this.scrollKey,
    this.physics,
    this.scrollCacheExtent,
    this.showStatusOverlay = true,
    super.key,
  });

  final bool isRefreshing;
  final Future<void> Function() onRefresh;
  final List<Widget> slivers;
  final Key? scrollKey;
  final ScrollPhysics? physics;
  final ScrollCacheExtent? scrollCacheExtent;
  final bool showStatusOverlay;

  @override
  Widget build(BuildContext context) {
    final scrollView = CustomScrollView(
      key: scrollKey,
      physics: physics ?? pullToRefreshScrollPhysics,
      scrollCacheExtent: scrollCacheExtent,
      slivers: [
        CupertinoSliverRefreshControl(onRefresh: onRefresh),
        ...slivers,
      ],
    );

    if (!showStatusOverlay) return scrollView;

    return RefreshStatusOverlay(isRefreshing: isRefreshing, child: scrollView);
  }
}
