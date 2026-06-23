import 'package:crypto_tracker_app/features/home/data/datasource/market_overview_local_datasource.dart';
import 'package:crypto_tracker_app/features/home/data/dto/global_market_dto.dart';
import 'package:crypto_tracker_app/features/home/data/dto/trending_coin_dto.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/hive_test_store.dart';

void main() {
  late MarketOverviewLocalDataSourceImpl dataSource;

  setUp(() async {
    dataSource = MarketOverviewLocalDataSourceImpl(await openTestCacheStore());
  });

  test('returns null before anything is cached', () {
    expect(dataSource.readGlobal(), isNull);
    expect(dataSource.readTrending(), isNull);
  });

  test('round-trips global market data', () async {
    const dto = GlobalMarketDto(
      totalMarketCap: 100,
      marketCapChangePercentage24h: 1.5,
      totalVolume: 50,
    );
    await dataSource.cacheGlobal(dto);

    final cached = dataSource.readGlobal();
    expect(cached!.data.toEntity().totalMarketCap, 100);
  });

  test('round-trips trending coins', () async {
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
    await dataSource.cacheTrending(dtos);

    final cached = dataSource.readTrending();
    expect(cached!.data.single.toEntity().id, 'bonk');
  });
}
