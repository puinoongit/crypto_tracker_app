import 'package:crypto_tracker_app/features/coin_detail/data/datasource/coin_detail_local_datasource.dart';
import 'package:crypto_tracker_app/features/coin_detail/data/dto/coin_detail_dto.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/fixtures.dart';
import '../../../helpers/hive_test_store.dart';

void main() {
  late CoinDetailLocalDataSourceImpl dataSource;

  setUp(() async {
    dataSource = CoinDetailLocalDataSourceImpl(await openTestCacheStore());
  });

  test('returns null when nothing cached', () {
    expect(dataSource.read('bitcoin'), isNull);
  });

  test('caches a detail and reads it back', () async {
    final dto = CoinDetailDto.fromApi(coinDetailApiJson());

    await dataSource.cache(dto);
    final cached = dataSource.read('bitcoin');

    expect(cached, isNotNull);
    expect(cached!.data.toEntity().currentPrice, 50000);
  });
}
