import 'package:crypto_tracker_app/features/favorites/domain/repository/favorites_repository.dart';
import 'package:crypto_tracker_app/features/favorites/domain/usecase/get_favorite_ids.dart';
import 'package:crypto_tracker_app/features/favorites/domain/usecase/toggle_favorite.dart';
import 'package:crypto_tracker_app/features/favorites/presentation/favorites_providers.dart';
import 'package:crypto_tracker_app/features/favorites/presentation/view_model/favorites_controller.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/fixtures.dart';

/// In-memory favorites repository so the controller can be tested without Hive.
class FakeFavoritesRepository implements FavoritesRepository {
  final List<String> _ids = [];

  @override
  List<String> getFavoriteIds() => List.unmodifiable(_ids);

  @override
  bool isFavorite(String coinId) => _ids.contains(coinId);

  @override
  Future<void> add(String coinId) async {
    _ids.remove(coinId);
    _ids.insert(0, coinId);
  }

  @override
  Future<void> remove(String coinId) async => _ids.remove(coinId);
}

void main() {
  late FakeFavoritesRepository repo;

  setUp(() => repo = FakeFavoritesRepository());

  ProviderContainer makeContainer() {
    final container = ProviderContainer(
      overrides: [
        getFavoriteIdsUseCaseProvider.overrideWithValue(GetFavoriteIds(repo)),
        toggleFavoriteUseCaseProvider.overrideWithValue(ToggleFavorite(repo)),
      ],
    );
    addTearDown(container.dispose);
    return container;
  }

  test('starts empty', () {
    final container = makeContainer();
    expect(container.read(favoritesControllerProvider), isEmpty);
  });

  test('toggle adds then removes a coin id and updates the selector', () async {
    final container = makeContainer();
    final notifier = container.read(favoritesControllerProvider.notifier);
    final coin = buildCoin();

    await notifier.toggle(coin.id);
    expect(container.read(favoritesControllerProvider), [coin.id]);
    expect(container.read(isFavoriteProvider(coin.id)), isTrue);

    await notifier.toggle(coin.id);
    expect(container.read(favoritesControllerProvider), isEmpty);
    expect(container.read(isFavoriteProvider(coin.id)), isFalse);
  });
}
