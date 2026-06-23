import 'package:crypto_tracker_app/core/cache/cache_policy.dart';
import 'package:crypto_tracker_app/core/error/failure.dart';
import 'package:crypto_tracker_app/core/utils/result.dart';
import 'package:crypto_tracker_app/features/home/domain/entity/coin.dart';
import 'package:crypto_tracker_app/features/home/domain/usecase/get_market_coins.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../helpers/fixtures.dart';
import '../../../helpers/mocks.dart';

void main() {
  late MockMarketRepository repository;
  late GetMarketCoins useCase;

  setUpAll(registerCommonFallbacks);

  setUp(() {
    repository = MockMarketRepository();
    useCase = GetMarketCoins(repository);
  });

  test(
    'forwards paging params to the repository and returns its result',
    () async {
      final coins = buildCoins(3);
      when(
        () => repository.getMarketCoins(
          page: any(named: 'page'),
          perPage: any(named: 'perPage'),
          forceRefresh: any(named: 'forceRefresh'),
          cacheTtl: any(named: 'cacheTtl'),
        ),
      ).thenAnswer((_) async => Result.ok(coins));

      final result = await useCase(
        const MarketPageParams(page: 2, perPage: 25, forceRefresh: true),
      );

      expect(result.valueOrNull, coins);
      verify(
        () =>
            repository.getMarketCoins(page: 2, perPage: 25, forceRefresh: true),
      ).called(1);
    },
  );

  test('forwards cacheTtl to the repository for polling', () async {
    when(
      () => repository.getMarketCoins(
        page: any(named: 'page'),
        perPage: any(named: 'perPage'),
        forceRefresh: any(named: 'forceRefresh'),
        cacheTtl: any(named: 'cacheTtl'),
      ),
    ).thenAnswer((_) async => Result.ok(buildCoins(1)));

    await useCase(
      MarketPageParams(
        page: 1,
        perPage: 20,
        cacheTtl: CachePolicy.marketPollTtl,
      ),
    );

    verify(
      () => repository.getMarketCoins(
        page: 1,
        perPage: 20,
        cacheTtl: CachePolicy.marketPollTtl,
      ),
    ).called(1);
  });

  test('propagates failures unchanged', () async {
    when(
      () => repository.getMarketCoins(
        page: any(named: 'page'),
        perPage: any(named: 'perPage'),
        forceRefresh: any(named: 'forceRefresh'),
        cacheTtl: any(named: 'cacheTtl'),
      ),
    ).thenAnswer((_) async => const Result<List<Coin>>.err(TimeoutFailure()));

    final result = await useCase(const MarketPageParams(page: 1, perPage: 25));

    expect(result.isErr, isTrue);
  });
}
