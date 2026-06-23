import 'package:flutter/rendering.dart';

/// Conservative defaults tuned for low-RAM devices and battery life.
///
/// Applied app-wide so list scrolling, image decoding, and background polling
/// stay within a small memory and network budget.
abstract final class PerformanceConfig {
  /// Decoded coin logos kept in the in-memory image cache.
  static const int imageCacheMaxEntries = 40;

  /// ~24 MiB cap for decoded images (logos are small; this prevents unbounded growth).
  static const int imageCacheMaxBytes = 24 << 20;

  /// Sparkline points stored per coin in memory and on disk (down from ~168 API points).
  static const int storedSparklinePoints = 36;

  /// List prefetch window — lower values use less RAM off-screen.
  static const ScrollCacheExtent listCacheExtent = ScrollCacheExtent.pixels(
    200,
  );

  /// Cap in-memory market pages (page size × this = max coins loaded via pagination).
  static const int maxMarketPages = 5;

  /// Max wait on the splash screen for the first market payload.
  static const Duration marketPrefetchTimeout = Duration(seconds: 15);
}
