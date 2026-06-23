import 'package:crypto_tracker_app/core/cache/cache_store.dart';
import 'package:crypto_tracker_app/core/error/exceptions.dart';
import 'package:crypto_tracker_app/core/error/failure.dart';
import 'package:crypto_tracker_app/features/coin_detail/data/dto/coin_detail_dto.dart';
import 'package:crypto_tracker_app/features/coin_detail/data/repository/coin_detail_repository_impl.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../helpers/fixtures.dart';
import '../../../helpers/mocks.dart';

void main() {
  late MockCoinDetailRemoteDataSource remote;
  late MockCoinDetailLocalDataSource local;
  late MockNetworkInfo networkInfo;
  late CoinDetailRepositoryImpl repository;

  final dto = CoinDetailDto.fromApi(coinDetailApiJson());

  CachedData<CoinDetailDto> cached(DateTime savedAt) =>
      CachedData(data: dto, savedAt: savedAt);

  setUp(() {
    remote = MockCoinDetailRemoteDataSource();
    local = MockCoinDetailLocalDataSource();
    networkInfo = MockNetworkInfo();
    repository = CoinDetailRepositoryImpl(
      remote: remote,
      local: local,
      networkInfo: networkInfo,
    );
  });

  test('serves fresh cache without hitting the network', () async {
    when(() => local.read('bitcoin')).thenReturn(cached(DateTime.now()));

    final result = await repository.getCoinDetail('bitcoin');

    expect(result.valueOrNull?.id, 'bitcoin');
    verifyNever(() => remote.fetchCoinDetail(any()));
  });

  test('fetches and caches when cache is stale and online', () async {
    when(
      () => local.read('bitcoin'),
    ).thenReturn(cached(DateTime.now().subtract(const Duration(hours: 1))));
    when(() => networkInfo.isConnected).thenAnswer((_) async => true);
    when(() => remote.fetchCoinDetail('bitcoin')).thenAnswer((_) async => dto);
    when(() => local.cache(dto)).thenAnswer((_) async {});

    final result = await repository.getCoinDetail('bitcoin');

    expect(result.isOk, isTrue);
    verify(() => local.cache(dto)).called(1);
  });

  test('falls back to cache on remote failure', () async {
    when(
      () => local.read('bitcoin'),
    ).thenReturn(cached(DateTime.now().subtract(const Duration(hours: 1))));
    when(() => networkInfo.isConnected).thenAnswer((_) async => true);
    when(
      () => remote.fetchCoinDetail('bitcoin'),
    ).thenThrow(const ServerException(statusCode: 500));

    final result = await repository.getCoinDetail('bitcoin');

    expect(result.valueOrNull, isNotNull);
  });

  test('offline with no cache returns CacheFailure', () async {
    when(() => local.read('bitcoin')).thenReturn(null);
    when(() => networkInfo.isConnected).thenAnswer((_) async => false);

    final result = await repository.getCoinDetail('bitcoin');

    result.fold((f) => expect(f, isA<CacheFailure>()), (_) => fail('ok'));
  });
}
