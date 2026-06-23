import 'package:crypto_tracker_app/core/cache/cache_policy.dart';
import 'package:crypto_tracker_app/core/cache/cache_store.dart';
import 'package:crypto_tracker_app/core/error/failure.dart';
import 'package:crypto_tracker_app/core/error/exceptions.dart';
import 'package:crypto_tracker_app/features/home/data/dto/coin_market_dto.dart';
import 'package:crypto_tracker_app/features/home/data/repository/market_repository_impl.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../helpers/fixtures.dart';
import '../../../helpers/mocks.dart';

void main() {
  late MockMarketRemoteDataSource remote;
  late MockMarketLocalDataSource local;
  late MockNetworkInfo networkInfo;
  late MarketRepositoryImpl repository;

  final dtos = [CoinMarketDto.fromJson(marketJson())];

  CachedData<List<CoinMarketDto>> cached(DateTime savedAt) =>
      CachedData(data: dtos, savedAt: savedAt);

  setUp(() {
    remote = MockMarketRemoteDataSource();
    local = MockMarketLocalDataSource();
    networkInfo = MockNetworkInfo();
    repository = MarketRepositoryImpl(
      remote: remote,
      local: local,
      networkInfo: networkInfo,
    );
  });

  group('getMarketCoins (online)', () {
    setUp(
      () => when(() => networkInfo.isConnected).thenAnswer((_) async => true),
    );

    test('fetches from remote, caches, and maps DTOs to entities', () async {
      when(() => local.readPage(1)).thenReturn(null);
      when(
        () => remote.fetchMarketCoins(
          page: any(named: 'page'),
          perPage: any(named: 'perPage'),
        ),
      ).thenAnswer((_) async => dtos);
      when(() => local.cachePage(any(), any())).thenAnswer((_) async {});

      final result = await repository.getMarketCoins(page: 1, perPage: 25);

      expect(result.valueOrNull, isNotNull);
      expect(result.valueOrNull!.first.id, 'bitcoin');
      verify(() => local.cachePage(1, dtos)).called(1);
    });

    test('serves a fresh cached page without hitting the network', () async {
      when(() => local.readPage(2)).thenReturn(cached(DateTime.now()));

      final result = await repository.getMarketCoins(page: 2, perPage: 20);

      expect(result.isOk, isTrue);
      verifyNever(
        () => remote.fetchMarketCoins(
          page: any(named: 'page'),
          perPage: any(named: 'perPage'),
        ),
      );
    });

    test(
      'serves a fresh cached first page without hitting the network',
      () async {
        when(() => local.readPage(1)).thenReturn(cached(DateTime.now()));

        final result = await repository.getMarketCoins(page: 1, perPage: 20);

        expect(result.isOk, isTrue);
        verifyNever(
          () => remote.fetchMarketCoins(
            page: any(named: 'page'),
            perPage: any(named: 'perPage'),
          ),
        );
      },
    );

    test(
      'refetches when cache is older than custom cacheTtl (poll window)',
      () async {
        when(() => local.readPage(1)).thenReturn(
          cached(DateTime.now().subtract(const Duration(minutes: 3))),
        );
        when(
          () => remote.fetchMarketCoins(
            page: any(named: 'page'),
            perPage: any(named: 'perPage'),
          ),
        ).thenAnswer((_) async => dtos);
        when(() => local.cachePage(any(), any())).thenAnswer((_) async {});

        await repository.getMarketCoins(
          page: 1,
          perPage: 20,
          cacheTtl: CachePolicy.marketPollTtl,
        );

        verify(() => remote.fetchMarketCoins(page: 1, perPage: 20)).called(1);
      },
    );

    test(
      'serves cache within custom cacheTtl without hitting the network',
      () async {
        when(() => local.readPage(1)).thenReturn(
          cached(DateTime.now().subtract(const Duration(seconds: 30))),
        );

        final result = await repository.getMarketCoins(
          page: 1,
          perPage: 20,
          cacheTtl: CachePolicy.marketPollTtl,
        );

        expect(result.isOk, isTrue);
        verifyNever(
          () => remote.fetchMarketCoins(
            page: any(named: 'page'),
            perPage: any(named: 'perPage'),
          ),
        );
      },
    );

    test(
      'keeps default marketTtl for pagination when poll TTL would be expired',
      () async {
        when(() => local.readPage(1)).thenReturn(
          cached(DateTime.now().subtract(const Duration(minutes: 3))),
        );

        final result = await repository.getMarketCoins(page: 1, perPage: 20);

        expect(result.isOk, isTrue);
        verifyNever(
          () => remote.fetchMarketCoins(
            page: any(named: 'page'),
            perPage: any(named: 'perPage'),
          ),
        );
      },
    );

    test('forceRefresh bypasses fresh cache and fetches', () async {
      when(() => local.readPage(1)).thenReturn(cached(DateTime.now()));
      when(
        () => remote.fetchMarketCoins(
          page: any(named: 'page'),
          perPage: any(named: 'perPage'),
        ),
      ).thenAnswer((_) async => dtos);
      when(() => local.cachePage(any(), any())).thenAnswer((_) async {});

      await repository.getMarketCoins(page: 1, perPage: 25, forceRefresh: true);

      verify(() => remote.fetchMarketCoins(page: 1, perPage: 25)).called(1);
    });

    test('falls back to cached page on remote failure', () async {
      when(
        () => local.readPage(1),
      ).thenReturn(cached(DateTime.now().subtract(const Duration(hours: 1))));
      when(
        () => remote.fetchMarketCoins(
          page: any(named: 'page'),
          perPage: any(named: 'perPage'),
        ),
      ).thenThrow(const ServerException(statusCode: 500));

      final result = await repository.getMarketCoins(page: 1, perPage: 25);

      expect(result.valueOrNull, isNotNull);
    });

    test(
      'returns the mapped failure when paging (page>1) and no cache',
      () async {
        when(() => local.readPage(2)).thenReturn(null);
        when(
          () => remote.fetchMarketCoins(
            page: any(named: 'page'),
            perPage: any(named: 'perPage'),
          ),
        ).thenThrow(const ServerException(statusCode: 500));

        final result = await repository.getMarketCoins(page: 2, perPage: 25);

        expect(result.isErr, isTrue);
        result.fold((f) => expect(f, isA<ServerFailure>()), (_) => fail('ok'));
      },
    );
  });

  group('getMarketCoins (offline)', () {
    setUp(
      () => when(() => networkInfo.isConnected).thenAnswer((_) async => false),
    );

    test('returns cached data when available (even if stale)', () async {
      when(
        () => local.readPage(1),
      ).thenReturn(cached(DateTime.now().subtract(const Duration(days: 1))));

      final result = await repository.getMarketCoins(page: 1, perPage: 25);

      expect(result.valueOrNull, isNotNull);
      verifyNever(
        () => remote.fetchMarketCoins(
          page: any(named: 'page'),
          perPage: any(named: 'perPage'),
        ),
      );
    });

    test(
      'returns CacheFailure for the first page when nothing is cached',
      () async {
        when(() => local.readPage(1)).thenReturn(null);

        final result = await repository.getMarketCoins(page: 1, perPage: 25);

        result.fold((f) => expect(f, isA<CacheFailure>()), (_) => fail('ok'));
      },
    );
  });

  group('getMarketCoinsByIds (online)', () {
    setUp(
      () => when(() => networkInfo.isConnected).thenAnswer((_) async => true),
    );

    test('fetches by ids, caches, and preserves favorite order', () async {
      when(() => local.readFavorites()).thenReturn(null);
      when(
        () => remote.fetchMarketCoinsByIds(ids: any(named: 'ids')),
      ).thenAnswer((_) async => dtos);
      when(() => local.cacheFavorites(any())).thenAnswer((_) async {});

      final result = await repository.getMarketCoinsByIds(
        ids: const ['bitcoin'],
      );

      expect(result.valueOrNull!.single.id, 'bitcoin');
      verify(() => local.cacheFavorites(dtos)).called(1);
    });

    test('serves fresh favorites cache without hitting the network', () async {
      when(() => local.readFavorites()).thenReturn(cached(DateTime.now()));

      final result = await repository.getMarketCoinsByIds(
        ids: const ['bitcoin'],
      );

      expect(result.isOk, isTrue);
      verifyNever(() => remote.fetchMarketCoinsByIds(ids: any(named: 'ids')));
    });

    test('forceRefresh bypasses fresh favorites cache', () async {
      when(() => local.readFavorites()).thenReturn(cached(DateTime.now()));
      when(
        () => remote.fetchMarketCoinsByIds(ids: any(named: 'ids')),
      ).thenAnswer((_) async => dtos);
      when(() => local.cacheFavorites(any())).thenAnswer((_) async {});

      await repository.getMarketCoinsByIds(
        ids: const ['bitcoin'],
        forceRefresh: true,
      );

      verify(
        () => remote.fetchMarketCoinsByIds(ids: const ['bitcoin']),
      ).called(1);
    });
  });

  group('getMarketCoinsByIds (offline)', () {
    setUp(
      () => when(() => networkInfo.isConnected).thenAnswer((_) async => false),
    );

    test('returns cached favorites when available', () async {
      when(
        () => local.readFavorites(),
      ).thenReturn(cached(DateTime.now().subtract(const Duration(days: 1))));

      final result = await repository.getMarketCoinsByIds(
        ids: const ['bitcoin'],
      );

      expect(result.valueOrNull, isNotNull);
    });

    test('returns CacheFailure when nothing is cached', () async {
      when(() => local.readFavorites()).thenReturn(null);
      when(() => local.findCoinsInCachedPages(any())).thenReturn(const []);

      final result = await repository.getMarketCoinsByIds(
        ids: const ['bitcoin'],
      );

      result.fold((f) => expect(f, isA<CacheFailure>()), (_) => fail('ok'));
    });
  });
}
