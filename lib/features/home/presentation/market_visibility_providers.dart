import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:crypto_tracker_app/core/providers/core_providers.dart';
import 'package:crypto_tracker_app/core/settings/settings_controller.dart';
import 'package:crypto_tracker_app/features/home/presentation/view_model/home_view_model.dart';

final marketTabVisibleProvider = StateProvider<bool>((ref) => true);

/// Whether the app is in the foreground (`AppLifecycleState.resumed`).
final appInForegroundProvider = StateProvider<bool>((ref) => true);

/// Whether a coin-detail route is on screen (pauses market polling).
final detailScreenOpenCountProvider = StateProvider<int>((ref) => 0);

/// Drives optional foreground polling — only when every gate is open.
final marketPollingActiveProvider = Provider<bool>((ref) {
  final tabVisible = ref.watch(marketTabVisibleProvider);
  final inForeground = ref.watch(appInForegroundProvider);
  final detailOpen = ref.watch(detailScreenOpenCountProvider) > 0;
  final online = ref.watch(connectivityStatusProvider).value ?? false;
  final liveUpdates = ref.watch(
    settingsControllerProvider.select((s) => s.livePriceUpdates),
  );
  return tabVisible && inForeground && !detailOpen && online && liveUpdates;
});

/// Side-effect bridge: keeps polling in sync without rebuilding [homeViewModelProvider].
final homeMarketPollingProvider = Provider<void>((ref) {
  ref.listen(marketPollingActiveProvider, (previous, next) {
    ref.read(homeViewModelProvider.notifier).setMarketPollingActive(next);
  }, fireImmediately: true);
});
