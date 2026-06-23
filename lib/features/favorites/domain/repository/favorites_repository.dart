/// Domain contract for managing the user's favorite coin ids.
///
/// Favorites are local-only bookmarks. Market data (price, sparkline, etc.)
/// is resolved at presentation time from the loaded market list.
abstract interface class FavoritesRepository {
  /// Favorite coin ids, most-recently-added first.
  List<String> getFavoriteIds();

  bool isFavorite(String coinId);

  Future<void> add(String coinId);

  Future<void> remove(String coinId);
}
