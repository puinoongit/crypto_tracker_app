import 'package:crypto_tracker_app/features/favorites/data/repository/favorites_repository_impl.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/hive_test_store.dart';
import 'package:crypto_tracker_app/features/favorites/data/datasource/favorites_local_datasource.dart';

void main() {
  late FavoritesRepositoryImpl repository;

  setUp(() async {
    repository = FavoritesRepositoryImpl(
      FavoritesLocalDataSourceImpl(await openTestCacheStore()),
    );
  });

  test(
    'delegates add/isFavorite/getFavoriteIds/remove to local storage',
    () async {
      const coinId = 'bitcoin';
      expect(repository.isFavorite(coinId), isFalse);

      await repository.add(coinId);
      expect(repository.isFavorite(coinId), isTrue);
      expect(repository.getFavoriteIds().single, coinId);

      await repository.remove(coinId);
      expect(repository.getFavoriteIds(), isEmpty);
    },
  );
}
