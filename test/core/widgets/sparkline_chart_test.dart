import 'package:crypto_tracker_app/core/config/performance_config.dart';
import 'package:crypto_tracker_app/core/utils/sparkline_sampling.dart';
import 'package:crypto_tracker_app/core/widgets/sparkline_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test(
    'sampleSparklinePrices downsamples long series for list performance',
    () {
      final prices = List<double>.generate(168, (i) => i.toDouble());
      final sampled = sampleSparklinePrices(prices);

      expect(sampled.length, PerformanceConfig.storedSparklinePoints);
      expect(sampled.first, 0);
      expect(sampled.last, 167);
    },
  );

  testWidgets('renders a sparkline when at least two prices are provided', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: SparklineChart(
            prices: [10, 12, 11, 14, 13],
            color: Colors.green,
          ),
        ),
      ),
    );

    expect(find.byType(SparklineChart), findsOneWidget);
  });

  testWidgets('renders an empty placeholder when fewer than two prices', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: SparklineChart(prices: [10], color: Colors.green),
        ),
      ),
    );

    expect(find.byType(SparklineChart), findsOneWidget);
    expect(tester.widget<SparklineChart>(find.byType(SparklineChart)).prices, [
      10,
    ]);
  });
}
