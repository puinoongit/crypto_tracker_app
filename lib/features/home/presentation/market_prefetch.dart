import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:crypto_tracker_app/core/config/performance_config.dart';
import 'package:crypto_tracker_app/features/home/presentation/state/home_state.dart';
import 'package:crypto_tracker_app/features/home/presentation/view_model/home_view_model.dart';
import 'package:crypto_tracker_app/features/home/presentation/view_model/market_overview_view_model.dart';

/// Warms the market overview header and first coin page before the shell opens.
Future<void> prefetchMarketData(
  T Function<T>(ProviderListenable<T> provider) read, {
  Duration timeout = PerformanceConfig.marketPrefetchTimeout,
}) async {
  read(marketOverviewViewModelProvider);

  final deadline = DateTime.now().add(timeout);
  while (DateTime.now().isBefore(deadline)) {
    final overview = read(marketOverviewViewModelProvider);
    final home = read(homeViewModelProvider);

    if (overview.isHeaderComplete &&
        (home.status == HomeStatus.success ||
            home.status == HomeStatus.error)) {
      return;
    }

    await Future<void>.delayed(const Duration(milliseconds: 16));
  }
}
