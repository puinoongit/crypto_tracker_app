import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// Renders CoinGecko's hosted sparkline SVG for trending carousel cards.
///
/// The `/search/trending` payload includes a ready-made `data.sparkline` URL, so
/// we avoid an extra `/coins/markets` call just to draw a mini chart.
class TrendingSparkline extends StatelessWidget {
  const TrendingSparkline({
    required this.url,
    required this.color,
    this.width = double.infinity,
    this.height = 22,
    super.key,
  });

  final String url;
  final Color color;
  final double width;
  final double height;

  @override
  Widget build(BuildContext context) {
    if (url.isEmpty) {
      return SizedBox(width: width, height: height);
    }

    return RepaintBoundary(
      child: SvgPicture.network(
        url,
        width: width,
        height: height,
        fit: BoxFit.fitWidth,
        colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
        placeholderBuilder: (_) => SizedBox(width: width, height: height),
        errorBuilder: (_, _, _) => SizedBox(width: width, height: height),
      ),
    );
  }
}
