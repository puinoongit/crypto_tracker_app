import 'package:crypto_tracker_app/core/config/performance_config.dart';

/// Downsamples a 7-day hourly sparkline to a small fixed series for RAM and paint cost.
List<double> sampleSparklinePrices(List<double> prices) {
  const maxPoints = PerformanceConfig.storedSparklinePoints;
  if (prices.length <= maxPoints) return prices;

  final step = (prices.length - 1) / (maxPoints - 1);
  return List<double>.generate(
    maxPoints,
    (i) => prices[(i * step).round().clamp(0, prices.length - 1)],
    growable: false,
  );
}
