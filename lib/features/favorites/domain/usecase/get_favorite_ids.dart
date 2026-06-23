import 'package:crypto_tracker_app/features/favorites/domain/repository/favorites_repository.dart';

/// Returns the user's favorite coin ids, newest first.
class GetFavoriteIds {
  const GetFavoriteIds(this._repository);

  final FavoritesRepository _repository;

  List<String> call() => _repository.getFavoriteIds();
}
