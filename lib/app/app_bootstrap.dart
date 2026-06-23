import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:crypto_tracker_app/core/theme/app_theme.dart';
import 'package:crypto_tracker_app/features/home/presentation/market_prefetch.dart';
import 'app_shell.dart';

/// Keeps the native launch splash visible while market data is prefetched,
/// then hands off directly to [AppShell] without a second splash UI.
class AppBootstrap extends ConsumerStatefulWidget {
  const AppBootstrap({super.key});

  @override
  ConsumerState<AppBootstrap> createState() => _AppBootstrapState();
}

class _AppBootstrapState extends ConsumerState<AppBootstrap> {
  var _ready = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _warmMarket());
  }

  Future<void> _warmMarket() async {
    await prefetchMarketData(ref.read);
    if (!mounted) return;
    FlutterNativeSplash.remove();
    setState(() => _ready = true);
  }

  @override
  Widget build(BuildContext context) {
    if (_ready) return const AppShell();

    // Keep brand green during bootstrap so light/dark system theme matches the icon.
    return const ColoredBox(color: AppTheme.brand);
  }
}
