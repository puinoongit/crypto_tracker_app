import 'package:crypto_tracker_app/core/error/failure.dart';
import 'package:crypto_tracker_app/core/utils/result.dart';
import 'package:crypto_tracker_app/features/favorites/domain/usecase/get_favorite_ids.dart';
import 'package:crypto_tracker_app/features/favorites/domain/usecase/toggle_favorite.dart';
import 'package:crypto_tracker_app/features/favorites/presentation/favorites_providers.dart';
import 'package:crypto_tracker_app/features/favorites/presentation/view/favorites_screen.dart';
import 'package:crypto_tracker_app/features/home/domain/entity/coin.dart';
import 'package:crypto_tracker_app/features/home/presentation/home_providers.dart';
import 'package:crypto_tracker_app/features/home/presentation/state/home_state.dart';
import 'package:crypto_tracker_app/features/home/presentation/view/widgets/market_list_skeleton.dart';
import 'package:crypto_tracker_app/features/home/presentation/view_model/home_view_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../helpers/fixtures.dart';
import '../../../helpers/mocks.dart';
import '../../../helpers/pump_app.dart';

class _IdleHomeViewModel extends HomeViewModel {
  @override
  HomeState build() => const HomeState(status: HomeStatus.success);
}

void main() {
  late FakeFavoritesRepository favoritesRepo;
  late MockGetMarketCoinsByIds getMarketCoinsByIds;

  setUpAll(registerCommonFallbacks);

  setUp(() {
    favoritesRepo = FakeFavoritesRepository();
    getMarketCoinsByIds = MockGetMarketCoinsByIds();
  });

  Future<void> pumpFavorites(WidgetTester tester) async {
    await pumpApp(
      tester,
      const Scaffold(body: FavoritesScreen()),
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
        homeViewModelProvider.overrideWith(_IdleHomeViewModel.new),
      ],
    );
  }

  testWidgets('shows empty state when there are no favorites', (tester) async {
    await pumpFavorites(tester);

    expect(find.text('No favorites yet'), findsOneWidget);
    expect(
      find.text('Tap the star on any coin to add it here.'),
      findsOneWidget,
    );
  });

  testWidgets('shows loading then favorite coins', (tester) async {
    final coin = buildCoin();
    await favoritesRepo.add(coin.id);

    when(
      () => getMarketCoinsByIds(any()),
    ).thenAnswer((_) async => Result.ok([coin]));

    await pumpFavorites(tester);
    expect(find.byType(MarketListSkeleton), findsOneWidget);

    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));

    expect(find.byType(MarketListSkeleton), findsNothing);
    expect(find.text('Bitcoin'), findsOneWidget);
  });

  testWidgets('shows an error view with retry on failure', (tester) async {
    await favoritesRepo.add('bitcoin');

    when(() => getMarketCoinsByIds(any())).thenAnswer(
      (_) async => const Result<List<Coin>>.err(NoInternetFailure()),
    );

    await pumpFavorites(tester);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));

    expect(find.text('No internet connection'), findsOneWidget);
    expect(find.text('Retry'), findsOneWidget);
  });

  testWidgets('uses market-list prices when the coin is already loaded there', (
    tester,
  ) async {
    final favoriteCoin = buildCoin(price: 100);
    final marketCoin = buildCoin(price: 64_939);
    await favoritesRepo.add(favoriteCoin.id);

    when(
      () => getMarketCoinsByIds(any()),
    ).thenAnswer((_) async => Result.ok([favoriteCoin]));

    await pumpApp(
      tester,
      const Scaffold(body: FavoritesScreen()),
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
        homeViewModelProvider.overrideWith(
          () => _HomeViewModelWithCoins([marketCoin]),
        ),
      ],
    );

    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));

    expect(find.text(r'$64,939.00'), findsOneWidget);
    expect(find.text(r'$100.00'), findsNothing);
  });
}

class _HomeViewModelWithCoins extends HomeViewModel {
  _HomeViewModelWithCoins(this.coins);

  final List<Coin> coins;

  @override
  HomeState build() => HomeState(status: HomeStatus.success, coins: coins);
}
