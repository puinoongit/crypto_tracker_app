import 'package:flutter/material.dart';

import 'package:crypto_tracker_app/core/utils/sparkline_sampling.dart';

/// A compact 7-day price sparkline for market list rows.
///
/// Drawn with [CustomPainter] (no chart package) and wrapped in a
/// [RepaintBoundary] so scrolling stays smooth with many items.
class SparklineChart extends StatelessWidget {
  const SparklineChart({
    required this.prices,
    required this.color,
    this.width = 72,
    this.height = 32,
    super.key,
  });

  final List<double> prices;
  final Color color;
  final double width;
  final double height;

  static List<double> samplePrices(List<double> prices) =>
      sampleSparklinePrices(prices);

  @override
  Widget build(BuildContext context) {
    if (prices.length < 2) {
      return SizedBox(width: width, height: height);
    }

    return RepaintBoundary(
      child: CustomPaint(
        size: Size(width, height),
        painter: _SparklinePainter(prices: prices, color: color),
      ),
    );
  }
}

class _SparklinePainter extends CustomPainter {
  _SparklinePainter({required this.prices, required this.color});

  final List<double> prices;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    var min = prices.first;
    var max = prices.first;
    for (final price in prices) {
      if (price < min) min = price;
      if (price > max) max = price;
    }

    final range = max - min;
    final effectiveRange = range == 0 ? 1.0 : range;
    final stepX = size.width / (prices.length - 1);

    final linePath = Path();
    final fillPath = Path();

    for (var i = 0; i < prices.length; i++) {
      final x = i * stepX;
      final normalized = (prices[i] - min) / effectiveRange;
      final y = size.height - (normalized * size.height);

      if (i == 0) {
        linePath.moveTo(x, y);
        fillPath.moveTo(x, size.height);
        fillPath.lineTo(x, y);
      } else {
        linePath.lineTo(x, y);
        fillPath.lineTo(x, y);
      }
    }

    fillPath.lineTo(size.width, size.height);
    fillPath.close();

    canvas.drawPath(
      fillPath,
      Paint()
        ..color = color.withValues(alpha: 0.12)
        ..style = PaintingStyle.fill,
    );

    canvas.drawPath(
      linePath,
      Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round,
    );
  }

  @override
  bool shouldRepaint(covariant _SparklinePainter oldDelegate) {
    return oldDelegate.prices != prices || oldDelegate.color != color;
  }
}
