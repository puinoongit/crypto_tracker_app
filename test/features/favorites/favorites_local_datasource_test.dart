import 'package:crypto_tracker_app/features/favorites/data/datasource/favorites_local_datasource.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/hive_test_store.dart';

void main() {
  late FavoritesLocalDataSourceImpl dataSource;

  setUp(() async {
    dataSource = FavoritesLocalDataSourceImpl(await openTestCacheStore());
  });

  test('starts empty', () {
    expect(dataSource.readAllIds(), isEmpty);
    expect(dataSource.contains('bitcoin'), isFalse);
  });

  test('persists, reports, and deletes a favorite id', () async {
    const coinId = 'bitcoin';

    await dataSource.put(coinId);
    expect(dataSource.contains(coinId), isTrue);
    expect(dataSource.readAllIds().single, coinId);

    await dataSource.delete(coinId);
    expect(dataSource.contains(coinId), isFalse);
    expect(dataSource.readAllIds(), isEmpty);
  });

  test('readAllIds returns newest-added first', () async {
    await dataSource.put('first');
    await Future<void>.delayed(const Duration(milliseconds: 5));
    await dataSource.put('second');

    final all = dataSource.readAllIds();
    expect(all.first, 'second');
    expect(all.last, 'first');
  });
}
