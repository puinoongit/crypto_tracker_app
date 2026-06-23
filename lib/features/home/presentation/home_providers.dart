import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:crypto_tracker_app/core/providers/core_providers.dart';
import 'package:crypto_tracker_app/features/home/data/datasource/market_local_datasource.dart';
import 'package:crypto_tracker_app/features/home/data/datasource/market_overview_local_datasource.dart';
import 'package:crypto_tracker_app/features/home/data/datasource/market_overview_remote_datasource.dart';
import 'package:crypto_tracker_app/features/home/data/datasource/market_remote_datasource.dart';
import 'package:crypto_tracker_app/features/home/data/repository/market_overview_repository_impl.dart';
import 'package:crypto_tracker_app/features/home/data/repository/market_repository_impl.dart';
import 'package:crypto_tracker_app/features/home/domain/repository/market_overview_repository.dart';
import 'package:crypto_tracker_app/features/home/domain/repository/market_repository.dart';
import 'package:crypto_tracker_app/features/home/domain/usecase/get_global_market.dart';
import 'package:crypto_tracker_app/features/home/domain/usecase/get_market_coins.dart';
import 'package:crypto_tracker_app/features/home/domain/usecase/get_market_coins_by_ids.dart';
import 'package:crypto_tracker_app/features/home/domain/usecase/get_trending_coins.dart';

/// Dependency graph for the Home feature, wired with Riverpod.
///
/// Each layer is its own provider so any of them can be overridden in isolation
/// for tests (e.g. swap the repository for a mock without touching the UI).

final marketRemoteDataSourceProvider = Provider<MarketRemoteDataSource>(
  (ref) => MarketRemoteDataSourceImpl(ref.watch(dioProvider)),
);

final marketLocalDataSourceProvider = Provider<MarketLocalDataSource>(
  (ref) => MarketLocalDataSourceImpl(ref.watch(marketCacheProvider)),
);

final marketRepositoryProvider = Provider<MarketRepository>(
  (ref) => MarketRepositoryImpl(
    remote: ref.watch(marketRemoteDataSourceProvider),
    local: ref.watch(marketLocalDataSourceProvider),
    networkInfo: ref.watch(networkInfoProvider),
  ),
);

final getMarketCoinsUseCaseProvider = Provider<GetMarketCoins>(
  (ref) => GetMarketCoins(ref.watch(marketRepositoryProvider)),
);

final getMarketCoinsByIdsUseCaseProvider = Provider<GetMarketCoinsByIds>(
  (ref) => GetMarketCoinsByIds(ref.watch(marketRepositoryProvider)),
);

// ── Market overview (global stats + trending) ───────────────────────────────
final marketOverviewRemoteDataSourceProvider =
    Provider<MarketOverviewRemoteDataSource>(
      (ref) => MarketOverviewRemoteDataSourceImpl(ref.watch(dioProvider)),
    );

final marketOverviewLocalDataSourceProvider =
    Provider<MarketOverviewLocalDataSource>(
      (ref) =>
          MarketOverviewLocalDataSourceImpl(ref.watch(marketCacheProvider)),
    );

final marketOverviewRepositoryProvider = Provider<MarketOverviewRepository>(
  (ref) => MarketOverviewRepositoryImpl(
    remote: ref.watch(marketOverviewRemoteDataSourceProvider),
    local: ref.watch(marketOverviewLocalDataSourceProvider),
    networkInfo: ref.watch(networkInfoProvider),
  ),
);

final getGlobalMarketUseCaseProvider = Provider<GetGlobalMarket>(
  (ref) => GetGlobalMarket(ref.watch(marketOverviewRepositoryProvider)),
);

final getTrendingCoinsUseCaseProvider = Provider<GetTrendingCoins>(
  (ref) => GetTrendingCoins(ref.watch(marketOverviewRepositoryProvider)),
);
