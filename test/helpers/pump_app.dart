import 'package:crypto_tracker_app/core/localization/generated/app_localizations.dart';
import 'package:crypto_tracker_app/core/error/failure.dart';
import 'package:crypto_tracker_app/core/providers/core_providers.dart';
import 'package:crypto_tracker_app/core/utils/result.dart';
import 'package:crypto_tracker_app/features/favorites/domain/repository/favorites_repository.dart';
import 'package:crypto_tracker_app/features/favorites/domain/usecase/get_favorite_ids.dart';
import 'package:crypto_tracker_app/features/favorites/domain/usecase/toggle_favorite.dart';
import 'package:crypto_tracker_app/features/favorites/presentation/favorites_providers.dart';
import 'package:crypto_tracker_app/features/home/domain/entity/global_market.dart';
import 'package:crypto_tracker_app/features/home/domain/entity/trending_coin.dart';
import 'package:crypto_tracker_app/features/home/domain/repository/market_overview_repository.dart';
import 'package:crypto_tracker_app/features/home/domain/usecase/get_global_market.dart';
import 'package:crypto_tracker_app/features/home/domain/usecase/get_trending_coins.dart';
import 'package:crypto_tracker_app/features/home/presentation/market_visibility_providers.dart';
import 'package:crypto_tracker_app/features/home/presentation/home_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

/// In-memory favorites repo so widget tests don't need Hive.
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

/// Empty overview repo so the markets header stays hidden in widget tests
/// (avoids real network/Hive). Returns failures → header simply not shown.
class EmptyMarketOverviewRepository implements MarketOverviewRepository {
  @override
  Future<Result<GlobalMarket>> getGlobalMarket({
    bool forceRefresh = false,
  }) async => const Result.err(UnknownFailure());

  @override
  Future<Result<List<TrendingCoin>>> getTrendingCoins({
    bool forceRefresh = false,
  }) async => const Result.ok([]);
}

/// Default overrides that keep widgets decoupled from platform plugins:
/// favorites backed by memory, overview stubbed, and connectivity forced online.
List<Override> defaultTestOverrides() {
  final repo = FakeFavoritesRepository();
  final overview = EmptyMarketOverviewRepository();
  return [
    getFavoriteIdsUseCaseProvider.overrideWithValue(GetFavoriteIds(repo)),
    toggleFavoriteUseCaseProvider.overrideWithValue(ToggleFavorite(repo)),
    getGlobalMarketUseCaseProvider.overrideWithValue(GetGlobalMarket(overview)),
    getTrendingCoinsUseCaseProvider.overrideWithValue(
      GetTrendingCoins(overview),
    ),
    connectivityStatusProvider.overrideWith((ref) => Stream.value(true)),
    marketPollingActiveProvider.overrideWith((ref) => false),
    marketTabVisibleProvider.overrideWith((ref) => true),
  ];
}

/// Flushes async overview + market-list work started on first frame.
Future<void> flushMarketJourney(WidgetTester tester) async {
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 50));
}

/// Pumps [child] inside a localized [MaterialApp] and a [ProviderScope].
Future<void> pumpApp(
  WidgetTester tester,
  Widget child, {
  List<Override> overrides = const [],
}) {
  return tester.pumpWidget(
    ProviderScope(
      overrides: [...defaultTestOverrides(), ...overrides],
      child: MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: child,
      ),
    ),
  );
}
