import 'package:crypto_tracker_app/core/localization/generated/app_localizations.dart';
import 'package:crypto_tracker_app/core/utils/result.dart';
import 'package:crypto_tracker_app/features/coin_detail/presentation/coin_detail_providers.dart';
import 'package:crypto_tracker_app/features/coin_detail/presentation/view/coin_detail_screen.dart';
import 'package:crypto_tracker_app/features/home/presentation/market_visibility_providers.dart';
import 'package:crypto_tracker_app/features/search/presentation/search_providers.dart';
import 'package:crypto_tracker_app/features/search/presentation/view_model/search_view_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../helpers/fixtures.dart';
import '../../../helpers/mocks.dart';
import '../../../helpers/pump_app.dart';

void main() {
  late MockGetCoinDetail useCase;

  setUpAll(registerCommonFallbacks);
  setUp(() {
    useCase = MockGetCoinDetail();
    when(() => useCase.peekCached(any())).thenReturn(null);
    when(
      () => useCase(any()),
    ).thenAnswer((_) async => Result.ok(buildCoinDetail()));
  });

  testWidgets('clears detail open count after leaving the detail screen', (
    tester,
  ) async {
    final container = ProviderContainer(
      overrides: [
        ...defaultTestOverrides(),
        getCoinDetailUseCaseProvider.overrideWithValue(useCase),
      ],
    );
    addTearDown(container.dispose);

    Future<void> pump(Widget home) {
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

    await pump(
      const CoinDetailScreen(coinId: 'bitcoin', fallbackName: 'Bitcoin'),
    );
    await tester.pump();
    expect(container.read(detailScreenOpenCountProvider), 1);

    await pump(const SizedBox.shrink());
    await tester.pump();
    expect(container.read(detailScreenOpenCountProvider), 0);
  });

  test('keeps search state when the market tab is hidden', () async {
    final local = MockSearchLocalDataSource();
    when(() => local.readLastSearchQuery()).thenReturn(null);
    when(() => local.readSearchHistory()).thenReturn(const []);
    when(() => local.saveLastSearchQuery(any())).thenAnswer((_) async {});
    when(() => local.clearLastSearchQuery()).thenAnswer((_) async {});
    when(() => local.addSearchHistoryEntry(any())).thenAnswer((_) async {});
    when(() => local.clearSearchHistory()).thenAnswer((_) async {});

    final searchCoins = MockSearchCoins();
    when(
      () => searchCoins(any()),
    ).thenAnswer((_) async => Result.ok(buildCoins(1, startRank: 42)));

    final container = ProviderContainer(
      overrides: [
        ...defaultTestOverrides(),
        searchCoinsUseCaseProvider.overrideWithValue(searchCoins),
        searchLocalDataSourceProvider.overrideWithValue(local),
      ],
    );
    addTearDown(container.dispose);

    await container.read(searchViewModelProvider.notifier).search('pepe');
    expect(container.read(searchViewModelProvider).canSearch, isTrue);

    container.read(marketTabVisibleProvider.notifier).state = false;

    final state = container.read(searchViewModelProvider);
    expect(state.query, 'pepe');
    expect(state.results, hasLength(1));
  });
}
