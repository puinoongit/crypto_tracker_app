import 'package:crypto_tracker_app/features/home/data/datasource/market_local_datasource.dart';
import 'package:crypto_tracker_app/features/home/data/dto/coin_market_dto.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/fixtures.dart';
import '../../../helpers/hive_test_store.dart';

void main() {
  late MarketLocalDataSourceImpl dataSource;

  setUp(() async {
    dataSource = MarketLocalDataSourceImpl(await openTestCacheStore());
  });

  test('returns null for an uncached page', () {
    expect(dataSource.readPage(1), isNull);
  });

  test('caches a page and reads it back as DTOs', () async {
    final dtos = [
      CoinMarketDto.fromJson(marketJson()),
      CoinMarketDto.fromJson(marketJson(id: 'ethereum', rank: 2)),
    ];

    await dataSource.cachePage(1, dtos);
    final cached = dataSource.readPage(1);

    expect(cached, isNotNull);
    expect(cached!.data, hasLength(2));
    expect(cached.data.first.id, 'bitcoin');
    expect(
      cached.savedAt.isBefore(DateTime.now().add(const Duration(seconds: 1))),
      isTrue,
    );
  });

  test('caches pages independently', () async {
    await dataSource.cachePage(1, [CoinMarketDto.fromJson(marketJson())]);
    await dataSource.cachePage(2, [
      CoinMarketDto.fromJson(marketJson(id: 'eth')),
    ]);

    expect(dataSource.readPage(1)!.data.first.id, 'bitcoin');
    expect(dataSource.readPage(2)!.data.first.id, 'eth');
  });
}
