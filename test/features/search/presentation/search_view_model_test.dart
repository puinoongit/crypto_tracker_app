import 'package:crypto_tracker_app/core/error/failure.dart';
import 'package:crypto_tracker_app/core/utils/result.dart';
import 'package:crypto_tracker_app/features/search/domain/usecase/search_coins.dart';
import 'package:crypto_tracker_app/features/search/presentation/search_providers.dart';
import 'package:crypto_tracker_app/features/search/presentation/view_model/search_view_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../helpers/fixtures.dart';
import '../../../helpers/mocks.dart';

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

  ProviderContainer makeContainer() {
    final container = ProviderContainer(
      overrides: [
        searchCoinsUseCaseProvider.overrideWithValue(searchCoins),
        searchLocalDataSourceProvider.overrideWithValue(local),
      ],
    );
    addTearDown(container.dispose);
    return container;
  }

  test(
    'sets loading before results arrive (no premature empty state)',
    () async {
      when(() => searchCoins(any())).thenAnswer((_) async {
        await Future<void>.delayed(const Duration(milliseconds: 50));
        return Result.ok(buildCoins(1));
      });

      final container = makeContainer();
      // ignore: unawaited_futures
      container.read(searchViewModelProvider.notifier).search('pepe');

      final loading = container.read(searchViewModelProvider);
      expect(loading.isLoading, isTrue);
      expect(loading.hasCompletedSearch, isFalse);
      expect(loading.results, isEmpty);

      await pumpEventQueue();
      await Future<void>.delayed(const Duration(milliseconds: 60));

      final done = container.read(searchViewModelProvider);
      expect(done.hasCompletedSearch, isTrue);
      expect(done.results, isNotEmpty);
    },
  );

  test('hits server search for queries with 2+ characters', () async {
    when(
      () => searchCoins(any()),
    ).thenAnswer((_) async => Result.ok(buildCoins(3, startRank: 500)));

    final container = makeContainer();
    await container.read(searchViewModelProvider.notifier).search('pepe');

    final state = container.read(searchViewModelProvider);
    expect(state.canSearch, isTrue);
    expect(state.results, hasLength(3));
    verify(() => local.saveLastSearchQuery('pepe')).called(1);
    verify(() => local.addSearchHistoryEntry('pepe')).called(1);
    verify(
      () => searchCoins(
        any(that: predicate<SearchCoinsParams>((p) => p.query == 'pepe')),
      ),
    ).called(1);
  });

  test('restores the last query from storage on first build', () async {
    when(() => local.readLastSearchQuery()).thenReturn('pepe');
    when(
      () => searchCoins(any()),
    ).thenAnswer((_) async => Result.ok(buildCoins(2, startRank: 100)));

    final container = makeContainer();
    container.read(searchViewModelProvider);
    await pumpEventQueue();

    final state = container.read(searchViewModelProvider);
    expect(state.query, 'pepe');
    expect(state.results, hasLength(2));
    verify(() => searchCoins(any())).called(1);
  });

  test('ignores stale server search responses', () async {
    when(() => searchCoins(any())).thenAnswer((invocation) async {
      final query =
          (invocation.positionalArguments.first as SearchCoinsParams).query;
      if (query == 'bitcoin') {
        await Future<void>.delayed(const Duration(milliseconds: 80));
        return Result.ok(buildCoins(1));
      }
      return Result.ok(buildCoins(1, startRank: 99));
    });

    final container = makeContainer();
    final notifier = container.read(searchViewModelProvider.notifier);
    // ignore: unawaited_futures
    notifier.search('bitcoin');
    await notifier.search('eth');
    await Future<void>.delayed(const Duration(milliseconds: 120));

    final state = container.read(searchViewModelProvider);
    expect(state.query, 'eth');
    expect(state.results.single.marketCapRank, 99);
  });

  test('clear resets query, results, and storage', () async {
    when(
      () => searchCoins(any()),
    ).thenAnswer((_) async => Result.ok(buildCoins(2, startRank: 100)));

    final container = makeContainer();
    await container.read(searchViewModelProvider.notifier).search('pepe');
    container.read(searchViewModelProvider.notifier).clear();

    final state = container.read(searchViewModelProvider);
    expect(state.query, isEmpty);
    expect(state.results, isEmpty);
    expect(state.hasQuery, isFalse);
    verify(() => local.clearLastSearchQuery()).called(1);
  });

  test('does not save history when search fails', () async {
    when(
      () => searchCoins(any()),
    ).thenAnswer((_) async => const Result.err(NoInternetFailure()));

    final container = makeContainer();
    await container.read(searchViewModelProvider.notifier).search('pepe');

    verifyNever(() => local.addSearchHistoryEntry(any()));
    verifyNever(() => local.saveLastSearchQuery(any()));
  });

  test('loads persisted history on build', () async {
    when(() => local.readSearchHistory()).thenReturn(['bitcoin', 'eth']);

    final container = makeContainer();
    final state = container.read(searchViewModelProvider);

    expect(state.history, ['bitcoin', 'eth']);
  });

  test('clearHistory wipes stored entries', () async {
    when(() => local.readSearchHistory()).thenReturn(['bitcoin']);

    final container = makeContainer();
    await container.read(searchViewModelProvider.notifier).clearHistory();

    verify(() => local.clearSearchHistory()).called(1);
    expect(container.read(searchViewModelProvider).history, isEmpty);
  });

  test('surfaces failures from the search use case', () async {
    when(
      () => searchCoins(any()),
    ).thenAnswer((_) async => const Result.err(NoInternetFailure()));

    final container = makeContainer();
    await container.read(searchViewModelProvider.notifier).search('pepe');

    expect(
      container.read(searchViewModelProvider).failure,
      isA<NoInternetFailure>(),
    );
  });
}
