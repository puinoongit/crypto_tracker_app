import 'package:crypto_tracker_app/core/utils/result.dart';
import 'package:crypto_tracker_app/features/search/presentation/search_providers.dart';
import 'package:crypto_tracker_app/features/search/presentation/view/search_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:crypto_tracker_app/core/localization/generated/app_localizations.dart';

import '../../../helpers/fixtures.dart';
import '../../../helpers/mocks.dart';
import '../../../helpers/pump_app.dart';

void main() {
  late MockSearchCoins searchCoins;
  late MockSearchLocalDataSource local;

  setUpAll(registerCommonFallbacks);
  setUp(() {
    searchCoins = MockSearchCoins();
    local = MockSearchLocalDataSource();
    when(() => local.readLastSearchQuery()).thenReturn(null);
    when(() => local.readSearchHistory()).thenReturn(const []);
    when(() => local.saveLastSearchQuery(any())).thenAnswer((_) async {});
    when(() => local.clearLastSearchQuery()).thenAnswer((_) async {});
    when(() => local.addSearchHistoryEntry(any())).thenAnswer((_) async {});
    when(() => local.clearSearchHistory()).thenAnswer((_) async {});
  });

  List<Override> searchOverrides() => [
    searchCoinsUseCaseProvider.overrideWithValue(searchCoins),
    searchLocalDataSourceProvider.overrideWithValue(local),
  ];

  Future<void> pumpSearch(WidgetTester tester) async {
    await pumpApp(
      tester,
      const Scaffold(body: SearchScreen()),
      overrides: searchOverrides(),
    );
  }

  testWidgets('shows idle prompt before typing', (tester) async {
    await pumpSearch(tester);
    expect(find.text('Search all coins'), findsOneWidget);
  });

  testWidgets('debounced server search shows remote results', (tester) async {
    when(
      () => searchCoins(any()),
    ).thenAnswer((_) async => Result.ok(buildCoins(1, startRank: 42)));

    await pumpSearch(tester);
    await tester.enterText(find.byType(TextField), 'pepe');
    await tester.pump(const Duration(milliseconds: 350));
    await tester.pump();

    expect(find.text('Coin 42'), findsOneWidget);
    verify(() => searchCoins(any())).called(1);
  });

  testWidgets('shows recent search chips when history exists', (tester) async {
    when(() => local.readSearchHistory()).thenReturn(['bitcoin', 'ethereum']);

    await pumpSearch(tester);

    expect(find.text('Recent searches'), findsOneWidget);
    expect(find.text('bitcoin'), findsOneWidget);
    expect(find.text('ethereum'), findsOneWidget);
    expect(find.text('Search all coins'), findsNothing);
  });

  testWidgets('tapping a history chip runs search', (tester) async {
    when(() => local.readSearchHistory()).thenReturn(['pepe']);
    when(
      () => searchCoins(any()),
    ).thenAnswer((_) async => Result.ok(buildCoins(1, startRank: 42)));

    await pumpSearch(tester);
    await tester.tap(find.text('pepe'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));

    expect(find.text('Coin 42'), findsOneWidget);
    verify(() => searchCoins(any())).called(1);
  });

  testWidgets('restores search text after the screen is rebuilt', (
    tester,
  ) async {
    when(
      () => searchCoins(any()),
    ).thenAnswer((_) async => Result.ok(buildCoins(1, startRank: 42)));

    final container = ProviderContainer(
      overrides: [...defaultTestOverrides(), ...searchOverrides()],
    );
    addTearDown(container.dispose);

    Future<void> pumpShell(Widget home) {
      return tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: home,
          ),
        ),
      );
    }

    await pumpShell(const Scaffold(body: SearchScreen()));
    await tester.enterText(find.byType(TextField), 'pepe');
    await tester.pump(const Duration(milliseconds: 350));
    await tester.pump();

    expect(find.text('Coin 42'), findsOneWidget);

    await pumpShell(const SizedBox.shrink());
    await tester.pump();

    await pumpShell(const Scaffold(body: SearchScreen()));
    await tester.pump();

    expect(find.text('Coin 42'), findsOneWidget);
    final field = tester.widget<TextField>(find.byType(TextField));
    expect(field.controller?.text, 'pepe');
  });
}
