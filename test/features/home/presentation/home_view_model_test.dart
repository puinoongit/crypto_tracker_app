import 'package:fake_async/fake_async.dart';
import 'package:crypto_tracker_app/core/cache/cache_policy.dart';
import 'package:crypto_tracker_app/core/config/api_config.dart';
import 'package:crypto_tracker_app/core/error/failure.dart';
import 'package:crypto_tracker_app/core/utils/result.dart';
import 'package:crypto_tracker_app/features/home/domain/entity/coin.dart';
import 'package:crypto_tracker_app/features/home/domain/usecase/get_market_coins.dart';
import 'package:crypto_tracker_app/features/home/presentation/home_providers.dart';
import 'package:crypto_tracker_app/features/home/presentation/market_visibility_providers.dart';
import 'package:crypto_tracker_app/features/home/presentation/state/home_state.dart';
import 'package:crypto_tracker_app/features/home/presentation/view_model/home_view_model.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mocktail/mocktail.dart';

import '../../../helpers/fixtures.dart';
import '../../../helpers/mocks.dart';

void main() {
  late MockGetMarketCoins useCase;

  setUpAll(registerCommonFallbacks);

  setUp(() {
    useCase = MockGetMarketCoins();
  });

  ProviderContainer makeContainer() {
    final container = ProviderContainer(
      overrides: [
        getMarketCoinsUseCaseProvider.overrideWithValue(useCase),
        marketPollingActiveProvider.overrideWith((ref) => false),
      ],
    );
    addTearDown(container.dispose);
    return container;
  }

  Future<void> bootstrap(ProviderContainer container) async {
    container.read(homeViewModelProvider);
    await container.read(homeViewModelProvider.notifier).loadInitial();
    await pumpEventQueue();
  }

  group('loadInitial', () {
    test('emits success with a full page and not end-of-list', () async {
      when(
        () => useCase(any()),
      ).thenAnswer((_) async => Result.ok(buildCoins(25)));

      final container = makeContainer();
      await bootstrap(container);

      final state = container.read(homeViewModelProvider);
      expect(state.status, HomeStatus.success);
      expect(state.coins, hasLength(25));
      expect(state.hasReachedEnd, isFalse);
    });

    test('a short first page marks end-of-list', () async {
      when(
        () => useCase(any()),
      ).thenAnswer((_) async => Result.ok(buildCoins(10)));

      final container = makeContainer();
      await bootstrap(container);

      expect(container.read(homeViewModelProvider).hasReachedEnd, isTrue);
    });

    test('emits error state on failure', () async {
      when(() => useCase(any())).thenAnswer(
        (_) async => const Result<List<Coin>>.err(NoInternetFailure()),
      );

      final container = makeContainer();
      await bootstrap(container);

      final state = container.read(homeViewModelProvider);
      expect(state.status, HomeStatus.error);
      expect(state.failure, isA<NoInternetFailure>());
    });
  });

  group('loadMore', () {
    void stubByPage() {
      when(() => useCase(any())).thenAnswer((invocation) async {
        final params = invocation.positionalArguments.first as MarketPageParams;
        if (params.page == 1) return Result.ok(buildCoins(25));
        return Result.ok(buildCoins(10, startRank: 26)); // partial → end
      });
    }

    test('appends the next page and preserves existing items', () async {
      stubByPage();
      final container = makeContainer();
      await bootstrap(container);

      await container.read(homeViewModelProvider.notifier).loadMore();

      final state = container.read(homeViewModelProvider);
      expect(state.coins, hasLength(35));
      expect(state.page, 2);
      expect(state.hasReachedEnd, isTrue);
    });

    test('prevents duplicate concurrent requests for the same page', () async {
      stubByPage();
      final container = makeContainer();
      await bootstrap(container);

      final notifier = container.read(homeViewModelProvider.notifier);
      final f1 = notifier.loadMore();
      final f2 = notifier.loadMore();
      await Future.wait([f1, f2]);

      verify(
        () => useCase(
          any(that: isA<MarketPageParams>().having((p) => p.page, 'page', 2)),
        ),
      ).called(1);
    });

    test('does not set isRefreshing while paginating', () async {
      stubByPage();
      final container = makeContainer();
      await bootstrap(container);

      await container.read(homeViewModelProvider.notifier).loadMore();

      expect(container.read(homeViewModelProvider).isRefreshing, isFalse);
    });
  });

  group('foreground polling', () {
    test('poll refresh uses cacheTtl instead of forceRefresh', () {
      fakeAsync((async) {
        when(
          () => useCase(any()),
        ).thenAnswer((_) async => Result.ok(buildCoins(25)));

        final container = makeContainer();
        container.read(homeViewModelProvider);
        container.read(homeViewModelProvider.notifier).loadInitial();
        async.elapse(Duration.zero);

        container
            .read(homeViewModelProvider.notifier)
            .setMarketPollingActive(true);
        async.elapse(ApiConfig.foregroundPollInterval);
        async.flushMicrotasks();

        verify(
          () => useCase(
            any(
              that: isA<MarketPageParams>()
                  .having((p) => p.forceRefresh, 'forceRefresh', isFalse)
                  .having(
                    (p) => p.cacheTtl,
                    'cacheTtl',
                    CachePolicy.marketPollTtl,
                  ),
            ),
          ),
        ).called(1);
      });
    });
  });

  group('refresh', () {
    test(
      'setMarketPollingActive clears isRefreshing when polling stops',
      () async {
        when(
          () => useCase(any()),
        ).thenAnswer((_) async => Result.ok(buildCoins(25)));

        final container = makeContainer();
        await bootstrap(container);

        when(() => useCase(any())).thenAnswer((_) async {
          await Future<void>.delayed(const Duration(days: 1));
          return Result.ok(buildCoins(25));
        });

        // ignore: unawaited_futures
        container.read(homeViewModelProvider.notifier).refresh();
        await pumpEventQueue();
        expect(container.read(homeViewModelProvider).isRefreshing, isTrue);

        container
            .read(homeViewModelProvider.notifier)
            .setMarketPollingActive(false);
        expect(container.read(homeViewModelProvider).isRefreshing, isFalse);
      },
    );

    test('clears isRefreshing after pull-to-refresh completes', () async {
      when(
        () => useCase(any()),
      ).thenAnswer((_) async => Result.ok(buildCoins(25)));

      final container = makeContainer();
      await bootstrap(container);

      await container.read(homeViewModelProvider.notifier).refresh();

      expect(container.read(homeViewModelProvider).isRefreshing, isFalse);
      verify(
        () => useCase(
          any(
            that: isA<MarketPageParams>().having(
              (p) => p.forceRefresh,
              'force',
              true,
            ),
          ),
        ),
      ).called(1);
    });
  });
}
