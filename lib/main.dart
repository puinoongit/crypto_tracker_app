import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app/app.dart';
import 'core/cache/hive_boxes.dart';
import 'core/config/performance_config.dart';
import 'core/platform/display_refresh_rate.dart';
import 'core/providers/core_providers.dart';

void _configureResourceLimits() {
  final imageCache = PaintingBinding.instance.imageCache;
  imageCache.maximumSize = PerformanceConfig.imageCacheMaxEntries;
  imageCache.maximumSizeBytes = PerformanceConfig.imageCacheMaxBytes;
}

/// Application entry point.
///
/// Hive is initialized and all boxes opened *before* `runApp` so the first frame
/// can read persisted settings synchronously (no theme/locale flash) and the
/// box providers can be injected via `ProviderScope` overrides.
Future<void> main() async {
  final widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);
  _configureResourceLimits();
  await syncDisplayRefreshRateWithSystem();
  await HiveInitializer.init();

  runApp(ProviderScope(overrides: buildBoxOverrides(), child: const App()));
}
