import 'package:crypto_tracker_app/features/favorites/domain/repository/favorites_repository.dart';
import 'package:crypto_tracker_app/features/favorites/data/datasource/favorites_local_datasource.dart';

/// Favorites repository backed entirely by local id storage.
class FavoritesRepositoryImpl implements FavoritesRepository {
  const FavoritesRepositoryImpl(this._local);

  final FavoritesLocalDataSource _local;

  @override
  List<String> getFavoriteIds() => _local.readAllIds();

  @override
  bool isFavorite(String coinId) => _local.contains(coinId);

  @override
  Future<void> add(String coinId) => _local.put(coinId);

  @override
  Future<void> remove(String coinId) => _local.delete(coinId);
}
