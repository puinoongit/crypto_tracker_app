import 'package:flutter/cupertino.dart';
import 'package:flutter/rendering.dart' show ScrollCacheExtent;

import 'pull_to_refresh_sliver_scroll.dart';

/// Cupertino-style pull-to-refresh with the shared status pill overlay.
///
/// Prefer passing [slivers] for list content so Android and iOS share the same
/// pull gesture and spinner.
class PullToRefreshList extends StatelessWidget {
  const PullToRefreshList({
    required this.isRefreshing,
    required this.onRefresh,
    required this.slivers,
    this.scrollKey,
    this.scrollCacheExtent,
    super.key,
  });

  final bool isRefreshing;
  final Future<void> Function() onRefresh;
  final List<Widget> slivers;
  final Key? scrollKey;
  final ScrollCacheExtent? scrollCacheExtent;

  @override
  Widget build(BuildContext context) {
    return PullToRefreshSliverScroll(
      isRefreshing: isRefreshing,
      onRefresh: onRefresh,
      scrollKey: scrollKey,
      scrollCacheExtent: scrollCacheExtent,
      slivers: slivers,
    );
  }
}
