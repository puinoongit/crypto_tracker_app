import 'package:crypto_tracker_app/core/error/failure.dart';
import 'package:crypto_tracker_app/core/utils/result.dart';
import 'package:crypto_tracker_app/features/home/domain/entity/global_market.dart';
import 'package:crypto_tracker_app/features/home/domain/entity/trending_coin.dart';
import 'package:crypto_tracker_app/features/home/domain/repository/market_overview_repository.dart';
import 'package:crypto_tracker_app/features/home/domain/usecase/get_global_market.dart';
import 'package:crypto_tracker_app/features/home/domain/usecase/get_trending_coins.dart';
import 'package:crypto_tracker_app/features/home/presentation/home_providers.dart';
import 'package:crypto_tracker_app/features/home/presentation/state/market_overview_state.dart';
import 'package:crypto_tracker_app/features/home/presentation/view_model/market_overview_view_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../helpers/fixtures.dart';
import '../../../helpers/mocks.dart';

/// Configurable fake repository for the overview.
class FakeOverviewRepository implements MarketOverviewRepository {
  FakeOverviewRepository({required this.global, required this.trending});

  Result<GlobalMarket> global;
  Result<List<TrendingCoin>> trending;

  @override
  Future<Result<GlobalMarket>> getGlobalMarket({
    bool forceRefresh = false,
  }) async => global;

  @override
  Future<Result<List<TrendingCoin>>> getTrendingCoins({
    bool forceRefresh = false,
  }) async => trending;
}

void main() {
  late MockGetMarketCoins marketCoins;

  setUpAll(registerCommonFallbacks);

  setUp(() {
    marketCoins = MockGetMarketCoins();
    when(
      () => marketCoins(any()),
    ).thenAnswer((_) async => Result.ok(buildCoins(5)));
  });

  ProviderContainer makeContainer(FakeOverviewRepository repo) {
    final container = ProviderContainer(
      overrides: [
        getGlobalMarketUseCaseProvider.overrideWithValue(GetGlobalMarket(repo)),
        getTrendingCoinsUseCaseProvider.overrideWithValue(
          GetTrendingCoins(repo),
        ),
        getMarketCoinsUseCaseProvider.overrideWithValue(marketCoins),
      ],
    );
    addTearDown(container.dispose);
    return container;
  }

  test('loads global then trending sequentially', () async {
    final repo = FakeOverviewRepository(
      global: Result.ok(buildGlobalMarket()),
      trending: Result.ok(buildTrendingCoins(count: 2)),
    );
    final container = makeContainer(repo);

    container.read(marketOverviewViewModelProvider);
    await pumpEventQueue();

    final state = container.read(marketOverviewViewModelProvider);
    expect(state.isLoading, isFalse);
    expect(state.isHeaderComplete, isTrue);
    expect(state.hasGlobal, isTrue);
    expect(state.trending, hasLength(2));
    verify(() => marketCoins(any())).called(1);
  });

  test('keeps section hidden when both requests fail', () async {
    final repo = FakeOverviewRepository(
      global: const Result.err(UnknownFailure()),
      trending: const Result.err(NoInternetFailure()),
    );
    final container = makeContainer(repo);

    container.read(marketOverviewViewModelProvider);
    await pumpEventQueue();

    final state = container.read(marketOverviewViewModelProvider);
    expect(state.hasGlobal, isFalse);
    expect(state.hasTrending, isFalse);
    expect(state.isLoading, isFalse);
    expect(state.isHeaderComplete, isTrue);
    verify(() => marketCoins(any())).called(1);
  });

  test('refresh keeps header complete while reloading', () async {
    final repo = FakeOverviewRepository(
      global: Result.ok(buildGlobalMarket()),
      trending: Result.ok(buildTrendingCoins(count: 1)),
    );
    final container = makeContainer(repo);

    container.read(marketOverviewViewModelProvider);
    await pumpEventQueue();

    final phases = <MarketOverviewPhase>[];
    container.listen(marketOverviewViewModelProvider, (prev, next) {
      phases.add(next.phase);
    });

    await container.read(marketOverviewViewModelProvider.notifier).refresh();
    await pumpEventQueue();

    expect(phases, isNot(contains(MarketOverviewPhase.loadingGlobal)));
    expect(
      container.read(marketOverviewViewModelProvider).isHeaderComplete,
      isTrue,
    );
  });

  test('emits loadingGlobal before trending completes', () async {
    final repo = FakeOverviewRepository(
      global: Result.ok(buildGlobalMarket()),
      trending: Result.ok(buildTrendingCoins(count: 1)),
    );
    final container = makeContainer(repo);

    final phases = <MarketOverviewPhase>[];
    container.listen(marketOverviewViewModelProvider, (prev, next) {
      phases.add(next.phase);
    });

    container.read(marketOverviewViewModelProvider);
    await pumpEventQueue();

    expect(
      phases,
      containsAllInOrder([
        MarketOverviewPhase.loadingGlobal,
        MarketOverviewPhase.loadingTrending,
        MarketOverviewPhase.complete,
      ]),
    );
  });
}
