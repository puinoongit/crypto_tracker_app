import 'package:crypto_tracker_app/core/error/failure.dart';
import 'package:crypto_tracker_app/core/utils/result.dart';
import 'package:crypto_tracker_app/features/home/domain/entity/global_market.dart';
import 'package:crypto_tracker_app/features/home/domain/entity/trending_coin.dart';
import 'package:crypto_tracker_app/features/home/domain/repository/market_overview_repository.dart';
import 'package:crypto_tracker_app/features/home/domain/usecase/get_global_market.dart';
import 'package:crypto_tracker_app/features/home/domain/usecase/get_trending_coins.dart';
import 'package:crypto_tracker_app/features/home/presentation/home_providers.dart';
import 'package:crypto_tracker_app/features/home/presentation/market_prefetch.dart';
import 'package:crypto_tracker_app/features/home/presentation/state/home_state.dart';
import 'package:crypto_tracker_app/features/home/presentation/view_model/home_view_model.dart';
import 'package:crypto_tracker_app/features/home/presentation/view_model/market_overview_view_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../helpers/fixtures.dart';
import '../../../helpers/mocks.dart';

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

  test('returns when overview and market list are ready', () async {
    final repo = FakeOverviewRepository(
      global: Result.ok(buildGlobalMarket()),
      trending: Result.ok(buildTrendingCoins(count: 1)),
    );
    final container = makeContainer(repo);

    await prefetchMarketData(container.read);

    final overview = container.read(marketOverviewViewModelProvider);
    final home = container.read(homeViewModelProvider);
    expect(overview.isHeaderComplete, isTrue);
    expect(home.status, HomeStatus.success);
    expect(home.coins, isNotEmpty);
  });

  test('returns on error so the shell can still open', () async {
    when(
      () => marketCoins(any()),
    ).thenAnswer((_) async => const Result.err(NoInternetFailure()));

    final repo = FakeOverviewRepository(
      global: const Result.err(UnknownFailure()),
      trending: const Result.err(UnknownFailure()),
    );
    final container = makeContainer(repo);

    await prefetchMarketData(container.read);

    expect(container.read(homeViewModelProvider).status, HomeStatus.error);
  });
}
