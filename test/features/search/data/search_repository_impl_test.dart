import 'package:crypto_tracker_app/core/cache/cache_store.dart';
import 'package:crypto_tracker_app/features/home/data/dto/coin_market_dto.dart';
import 'package:crypto_tracker_app/features/search/data/repository/search_repository_impl.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../helpers/fixtures.dart';
import '../../../helpers/mocks.dart';

void main() {
  late MockSearchRemoteDataSource remote;
  late MockSearchLocalDataSource local;
  late MockNetworkInfo networkInfo;
  late SearchRepositoryImpl repository;

  final dtos = [CoinMarketDto.fromJson(marketJson())];

  CachedData<List<CoinMarketDto>> cached(DateTime savedAt) =>
      CachedData(data: dtos, savedAt: savedAt);

  setUp(() {
    remote = MockSearchRemoteDataSource();
    local = MockSearchLocalDataSource();
    networkInfo = MockNetworkInfo();
    repository = SearchRepositoryImpl(
      remote: remote,
      local: local,
      networkInfo: networkInfo,
    );
  });

  group('searchCoins', () {
    setUp(
      () => when(() => networkInfo.isConnected).thenAnswer((_) async => true),
    );

    test('returns empty for queries shorter than min length', () async {
      final result = await repository.searchCoins(query: 'b');
      expect(result.valueOrNull, isEmpty);
      verifyNever(() => remote.searchCoinIds(query: any(named: 'query')));
    });

    test('searches ids then hydrates market rows', () async {
      when(() => local.readSearchResults('btc')).thenReturn(null);
      when(
        () => remote.searchCoinIds(query: 'btc'),
      ).thenAnswer((_) async => ['bitcoin']);
      when(
        () => remote.fetchMarketCoinsByIds(ids: const ['bitcoin']),
      ).thenAnswer((_) async => dtos);
      when(
        () => local.cacheSearchResults('btc', any()),
      ).thenAnswer((_) async {});

      final result = await repository.searchCoins(query: 'btc');

      expect(result.valueOrNull!.first.id, 'bitcoin');
      verify(() => local.cacheSearchResults('btc', dtos)).called(1);
    });

    test('serves fresh cached search without network', () async {
      when(
        () => local.readSearchResults('btc'),
      ).thenReturn(cached(DateTime.now()));

      final result = await repository.searchCoins(query: 'btc');

      expect(result.isOk, isTrue);
      verifyNever(() => remote.searchCoinIds(query: any(named: 'query')));
    });
  });
}
