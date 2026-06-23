import 'dart:io';

import 'package:crypto_tracker_app/app/settings_sheet.dart';
import 'package:crypto_tracker_app/core/localization/generated/app_localizations.dart';
import 'package:crypto_tracker_app/core/providers/core_providers.dart';
import 'package:crypto_tracker_app/core/settings/settings_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';

import '../helpers/pump_app.dart';

void main() {
  late Directory tempDir;
  late Box<String> settingsBox;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('settings_sheet_test');
    Hive.init(tempDir.path);
    settingsBox = await Hive.openBox<String>('settings');
  });

  tearDown(() async {
    await settingsBox.deleteFromDisk();
    await Hive.close();
    await tempDir.delete(recursive: true);
  });

  Future<void> pumpSettings(WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          settingsBoxProvider.overrideWithValue(settingsBox),
          ...defaultTestOverrides(),
        ],
        child: const MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(body: SettingsSheet()),
        ),
      ),
    );
    await tester.pump();
  }

  testWidgets('shows theme and language controls', (tester) async {
    await pumpSettings(tester);

    expect(find.text('Theme'), findsOneWidget);
    expect(find.text('System'), findsWidgets);
    expect(find.text('Light'), findsOneWidget);
    expect(find.text('Dark'), findsOneWidget);
    expect(find.text('English'), findsOneWidget);
    expect(find.text('ไทย'), findsOneWidget);
  });

  testWidgets('persists dark theme selection', (tester) async {
    await pumpSettings(tester);

    final container = ProviderScope.containerOf(
      tester.element(find.byType(SettingsSheet)),
    );
    await tester.runAsync(
      () => container
          .read(settingsControllerProvider.notifier)
          .setThemeMode(ThemeMode.dark),
    );
    await tester.pump();

    expect(settingsBox.get('theme_mode'), 'dark');
  });

  testWidgets('persists Thai locale selection', (tester) async {
    await pumpSettings(tester);

    final container = ProviderScope.containerOf(
      tester.element(find.byType(SettingsSheet)),
    );
    await tester.runAsync(
      () => container
          .read(settingsControllerProvider.notifier)
          .setLocale(const Locale('th')),
    );
    await tester.pump();

    expect(settingsBox.get('locale'), 'th');
  });

  testWidgets('shows live updates toggle defaulting to on', (tester) async {
    await pumpSettings(tester);

    expect(find.text('Auto-refresh market prices'), findsOneWidget);
    expect(find.byType(SwitchListTile), findsOneWidget);

    final switchTile = tester.widget<SwitchListTile>(
      find.byType(SwitchListTile),
    );
    expect(switchTile.value, isTrue);
  });

  testWidgets('persists disabling live price updates', (tester) async {
    await pumpSettings(tester);

    final container = ProviderScope.containerOf(
      tester.element(find.byType(SettingsSheet)),
    );
    await tester.runAsync(
      () => container
          .read(settingsControllerProvider.notifier)
          .setLivePriceUpdates(false),
    );
    await tester.pump();

    expect(settingsBox.get('live_price_updates'), 'false');
  });
}
