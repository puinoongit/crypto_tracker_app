import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:crypto_tracker_app/features/favorites/domain/usecase/get_favorite_ids.dart';
import 'package:crypto_tracker_app/features/favorites/domain/usecase/toggle_favorite.dart';
import 'package:crypto_tracker_app/features/favorites/presentation/favorites_providers.dart';

/// Single source of truth for favorite coin ids across the whole app.
class FavoritesController extends Notifier<List<String>> {
  late final GetFavoriteIds _getFavoriteIds;
  late final ToggleFavorite _toggleFavorite;

  @override
  List<String> build() {
    _getFavoriteIds = ref.watch(getFavoriteIdsUseCaseProvider);
    _toggleFavorite = ref.watch(toggleFavoriteUseCaseProvider);
    return _getFavoriteIds();
  }

  Future<void> toggle(String coinId) async {
    await _toggleFavorite(coinId);
    state = _getFavoriteIds();
  }

  bool isFavorite(String coinId) => state.contains(coinId);
}

final favoritesControllerProvider =
    NotifierProvider<FavoritesController, List<String>>(
      FavoritesController.new,
    );

/// Fine-grained membership selector so a list item rebuilds only when *its own*
/// favorite status changes, not when any favorite changes.
final isFavoriteProvider = Provider.family<bool, String>((ref, coinId) {
  return ref.watch(
    favoritesControllerProvider.select((ids) => ids.contains(coinId)),
  );
});
