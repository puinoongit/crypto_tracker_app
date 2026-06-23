import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:crypto_tracker_app/core/localization/generated/app_localizations.dart';
import 'package:crypto_tracker_app/core/widgets/offline_banner.dart';
import 'package:crypto_tracker_app/features/favorites/presentation/view/favorites_screen.dart';
import 'package:crypto_tracker_app/features/home/presentation/market_visibility_providers.dart';
import 'package:crypto_tracker_app/features/home/presentation/view/home_screen.dart';
import 'package:crypto_tracker_app/features/search/presentation/view/search_screen.dart';
import 'settings_sheet.dart';

/// Root navigation shell: Market, Search, and Favorites tabs.
///
/// Only the active tab is built to keep RAM low on entry-level devices.
/// [PageStorageKey] on each tab helps restore scroll position when switching back.
class AppShell extends ConsumerStatefulWidget {
  const AppShell({super.key});

  @override
  ConsumerState<AppShell> createState() => _AppShellState();
}

class _AppShellState extends ConsumerState<AppShell>
    with WidgetsBindingObserver {
  int _index = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didHaveMemoryPressure() {
    PaintingBinding.instance.imageCache.clear();
  }

  String _title(AppLocalizations l10n) => switch (_index) {
    0 => l10n.appTitle,
    1 => l10n.navSearch,
    _ => l10n.navFavorites,
  };

  @override
  Widget build(BuildContext context) {
    ref.watch(homeMarketPollingProvider);

    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(_title(l10n)),
        actions: [
          IconButton(
            icon: const Icon(Icons.tune_rounded),
            tooltip: l10n.settingsTheme,
            onPressed: () => SettingsSheet.show(context),
          ),
        ],
      ),
      body: Column(
        children: [
          const OfflineBanner(),
          Expanded(
            child: switch (_index) {
              0 => const HomeScreen(key: PageStorageKey<String>('home_tab')),
              1 => const SearchScreen(
                key: PageStorageKey<String>('search_tab'),
              ),
              _ => const FavoritesScreen(
                key: PageStorageKey<String>('favorites_tab'),
              ),
            },
          ),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) {
          ref.read(marketTabVisibleProvider.notifier).state = i == 0;
          setState(() => _index = i);
        },
        destinations: [
          NavigationDestination(
            icon: const Icon(Icons.show_chart_rounded),
            label: l10n.navMarket,
          ),
          NavigationDestination(
            icon: const Icon(Icons.search_rounded),
            label: l10n.navSearch,
          ),
          NavigationDestination(
            icon: const Icon(Icons.star_rounded),
            label: l10n.navFavorites,
          ),
        ],
      ),
    );
  }
}
