import 'package:crypto_tracker_app/core/platform/display_refresh_rate.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:crypto_tracker_app/core/localization/generated/app_localizations.dart';
import 'package:crypto_tracker_app/core/settings/settings_controller.dart';
import 'package:crypto_tracker_app/core/theme/app_theme.dart';
import 'app_bootstrap.dart';

/// Root application widget.
///
/// Watches [settingsControllerProvider] so theme mode and locale changes are
/// applied app-wide instantly. System theme/locale are honored by default
/// (ThemeMode.system + a null locale resolving via [localeResolutionCallback]).
class App extends ConsumerWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsControllerProvider);

    return DisplayRefreshRateLifecycleSync(
      child: MaterialApp(
        onGenerateTitle: (context) => AppLocalizations.of(context).appTitle,
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        darkTheme: AppTheme.dark,
        themeMode: settings.themeMode,
        locale: settings.locale,
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        home: const AppBootstrap(),
      ),
    );
  }
}
