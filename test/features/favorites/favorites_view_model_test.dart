import 'package:crypto_tracker_app/core/utils/result.dart';
import 'package:crypto_tracker_app/features/favorites/domain/usecase/get_favorite_ids.dart';
import 'package:crypto_tracker_app/features/favorites/domain/usecase/toggle_favorite.dart';
import 'package:crypto_tracker_app/features/favorites/presentation/favorites_providers.dart';
import 'package:crypto_tracker_app/features/favorites/presentation/state/favorites_state.dart';
import 'package:crypto_tracker_app/features/favorites/presentation/view_model/favorites_view_model.dart';
import 'package:crypto_tracker_app/features/home/domain/usecase/get_market_coins_by_ids.dart';
import 'package:crypto_tracker_app/features/home/presentation/home_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../helpers/fixtures.dart';
import '../../helpers/mocks.dart';
import 'favorites_controller_test.dart';

void main() {
  late FakeFavoritesRepository favoritesRepo;
  late MockGetMarketCoinsByIds getMarketCoinsByIds;

  setUpAll(registerCommonFallbacks);

  setUp(() {
    favoritesRepo = FakeFavoritesRepository();
    getMarketCoinsByIds = MockGetMarketCoinsByIds();
  });

  ProviderContainer makeContainer() {
    final container = ProviderContainer(
      overrides: [
        getFavoriteIdsUseCaseProvider.overrideWithValue(
          GetFavoriteIds(favoritesRepo),
        ),
        toggleFavoriteUseCaseProvider.overrideWithValue(
          ToggleFavorite(favoritesRepo),
        ),
        getMarketCoinsByIdsUseCaseProvider.overrideWithValue(
          getMarketCoinsByIds,
        ),
      ],
    );
    addTearDown(container.dispose);
    return container;
  }

  test('loads favorite coins from the market API on build', () async {
    final coin = buildCoin();
    await favoritesRepo.add(coin.id);

    when(
      () => getMarketCoinsByIds(any()),
    ).thenAnswer((_) async => Result.ok([coin]));

    final container = makeContainer();
    container.read(favoritesViewModelProvider);
    await pumpEventQueue();

    final state = container.read(favoritesViewModelProvider);
    expect(state.status, FavoritesStatus.success);
    expect(state.coins, [coin]);
    verify(() => getMarketCoinsByIds(any())).called(1);
  });

  test('refresh passes forceRefresh to the use case', () async {
    final coin = buildCoin();
    await favoritesRepo.add(coin.id);

    when(
      () => getMarketCoinsByIds(any()),
    ).thenAnswer((_) async => Result.ok([coin]));

    final container = makeContainer();
    container.read(favoritesViewModelProvider);
    await pumpEventQueue();

    await container.read(favoritesViewModelProvider.notifier).refresh();
    await pumpEventQueue();

    final captured = verify(
      () => getMarketCoinsByIds(captureAny()),
    ).captured.cast<MarketCoinsByIdsParams>();
    expect(captured.last.forceRefresh, isTrue);
  });

  group('mergeFavoriteCoinsWithMarket', () {
    test('uses market prices when the coin is already loaded there', () {
      final favoriteCoin = buildCoin(price: 100);
      final marketCoin = buildCoin(price: 200);

      final merged = mergeFavoriteCoinsWithMarket(
        favorites: [favoriteCoin],
        market: [marketCoin],
      );

      expect(merged.single.currentPrice, 200);
    });

    test('keeps favorite coin when it is not on the market list', () {
      final favoriteCoin = buildCoin(id: 'solana', price: 150);
      final marketCoin = buildCoin();

      final merged = mergeFavoriteCoinsWithMarket(
        favorites: [favoriteCoin],
        market: [marketCoin],
      );

      expect(merged.single.currentPrice, 150);
    });
  });
}
