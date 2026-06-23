import 'package:crypto_tracker_app/features/favorites/domain/repository/favorites_repository.dart';

/// Adds the coin id to favorites if absent, removes it if present.
///
/// Returns the resulting favorite state (`true` = now a favorite) so callers can
/// update UI without a second read.
class ToggleFavorite {
  const ToggleFavorite(this._repository);

  final FavoritesRepository _repository;

  Future<bool> call(String coinId) async {
    if (_repository.isFavorite(coinId)) {
      await _repository.remove(coinId);
      return false;
    }
    await _repository.add(coinId);
    return true;
  }
}
