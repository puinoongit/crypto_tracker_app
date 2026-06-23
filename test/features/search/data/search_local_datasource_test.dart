import 'package:crypto_tracker_app/features/search/data/datasource/search_local_datasource.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/hive_test_store.dart';

void main() {
  late SearchLocalDataSourceImpl dataSource;

  setUp(() async {
    dataSource = SearchLocalDataSourceImpl(await openTestCacheStore());
  });

  test('persists and reads the last search query', () async {
    expect(dataSource.readLastSearchQuery(), isNull);

    await dataSource.saveLastSearchQuery('pepe');
    expect(dataSource.readLastSearchQuery(), 'pepe');

    await dataSource.clearLastSearchQuery();
    expect(dataSource.readLastSearchQuery(), isNull);
  });

  test(
    'persists search history with most recent first and deduplication',
    () async {
      expect(dataSource.readSearchHistory(), isEmpty);

      await dataSource.addSearchHistoryEntry('bitcoin');
      await dataSource.addSearchHistoryEntry('ethereum');
      expect(dataSource.readSearchHistory(), ['ethereum', 'bitcoin']);

      await dataSource.addSearchHistoryEntry('bitcoin');
      expect(dataSource.readSearchHistory(), ['bitcoin', 'ethereum']);

      await dataSource.clearSearchHistory();
      expect(dataSource.readSearchHistory(), isEmpty);
    },
  );
}
