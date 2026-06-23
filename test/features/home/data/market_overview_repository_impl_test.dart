import 'package:crypto_tracker_app/core/cache/cache_store.dart';
import 'package:crypto_tracker_app/core/error/exceptions.dart';
import 'package:crypto_tracker_app/core/error/failure.dart';
import 'package:crypto_tracker_app/features/home/data/datasource/market_overview_local_datasource.dart';
import 'package:crypto_tracker_app/features/home/data/datasource/market_overview_remote_datasource.dart';
import 'package:crypto_tracker_app/features/home/data/dto/global_market_dto.dart';
import 'package:crypto_tracker_app/features/home/data/dto/trending_coin_dto.dart';
import 'package:crypto_tracker_app/features/home/data/repository/market_overview_repository_impl.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../helpers/mocks.dart';

class MockOverviewRemote extends Mock
    implements MarketOverviewRemoteDataSource {}

class MockOverviewLocal extends Mock implements MarketOverviewLocalDataSource {}

void main() {
  late MockOverviewRemote remote;
  late MockOverviewLocal local;
  late MockNetworkInfo networkInfo;
  late MarketOverviewRepositoryImpl repository;

  const globalDto = GlobalMarketDto(
    totalMarketCap: 100,
    marketCapChangePercentage24h: -0.42,
    totalVolume: 50,
  );

  setUpAll(() {
    registerFallbackValue(globalDto);
    registerFallbackValue(<TrendingCoinDto>[]);
  });

  setUp(() {
    remote = MockOverviewRemote();
    local = MockOverviewLocal();
    networkInfo = MockNetworkInfo();
    repository = MarketOverviewRepositoryImpl(
      remote: remote,
      local: local,
      networkInfo: networkInfo,
    );
  });

  group('getGlobalMarket', () {
    test('serves fresh cache without network', () async {
      when(
        () => local.readGlobal(),
      ).thenReturn(CachedData(data: globalDto, savedAt: DateTime.now()));

      final result = await repository.getGlobalMarket();

      expect(result.valueOrNull?.totalMarketCap, 100);
      verifyNever(() => remote.fetchGlobalMarket());
    });

    test('fetches and caches when stale and online', () async {
      when(() => local.readGlobal()).thenReturn(null);
      when(() => networkInfo.isConnected).thenAnswer((_) async => true);
      when(() => remote.fetchGlobalMarket()).thenAnswer((_) async => globalDto);
      when(() => local.cacheGlobal(any())).thenAnswer((_) async {});

      final result = await repository.getGlobalMarket();

      expect(result.isOk, isTrue);
      verify(() => local.cacheGlobal(globalDto)).called(1);
    });

    test('offline with no cache returns CacheFailure', () async {
      when(() => local.readGlobal()).thenReturn(null);
      when(() => networkInfo.isConnected).thenAnswer((_) async => false);

      final result = await repository.getGlobalMarket();

      result.fold((f) => expect(f, isA<CacheFailure>()), (_) => fail('ok'));
    });

    test(
      'falls back to mapped failure on remote error with no cache',
      () async {
        when(() => local.readGlobal()).thenReturn(null);
        when(() => networkInfo.isConnected).thenAnswer((_) async => true);
        when(
          () => remote.fetchGlobalMarket(),
        ).thenThrow(const ServerException(statusCode: 500));

        final result = await repository.getGlobalMarket();

        result.fold((f) => expect(f, isA<ServerFailure>()), (_) => fail('ok'));
      },
    );
  });

  group('getTrendingCoins', () {
    test('fetches, caches, and maps to entities when online', () async {
      final dtos = [
        const TrendingCoinDto(
          id: 'bonk',
          name: 'Bonk',
          symbol: 'bonk',
          thumb: 'x',
          marketCapRank: 102,
          priceChangePercentage24h: -1.36,
        ),
      ];
      when(() => local.readTrending()).thenReturn(null);
      when(() => networkInfo.isConnected).thenAnswer((_) async => true);
      when(() => remote.fetchTrendingCoins()).thenAnswer((_) async => dtos);
      when(() => local.cacheTrending(any())).thenAnswer((_) async {});

      final result = await repository.getTrendingCoins();

      expect(result.valueOrNull?.single.id, 'bonk');
      verify(() => local.cacheTrending(dtos)).called(1);
    });

    test('offline with no cache returns CacheFailure', () async {
      when(() => local.readTrending()).thenReturn(null);
      when(() => networkInfo.isConnected).thenAnswer((_) async => false);

      final result = await repository.getTrendingCoins();

      result.fold((f) => expect(f, isA<CacheFailure>()), (_) => fail('ok'));
    });
  });
}
