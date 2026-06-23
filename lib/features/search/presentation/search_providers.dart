import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:crypto_tracker_app/core/providers/core_providers.dart';
import 'package:crypto_tracker_app/features/search/data/datasource/search_local_datasource.dart';
import 'package:crypto_tracker_app/features/search/data/datasource/search_remote_datasource.dart';
import 'package:crypto_tracker_app/features/search/data/repository/search_repository_impl.dart';
import 'package:crypto_tracker_app/features/search/domain/repository/search_repository.dart';
import 'package:crypto_tracker_app/features/search/domain/usecase/search_coins.dart';

/// Dependency graph for the Search feature.

final searchRemoteDataSourceProvider = Provider<SearchRemoteDataSource>(
  (ref) => SearchRemoteDataSourceImpl(ref.watch(dioProvider)),
);

final searchLocalDataSourceProvider = Provider<SearchLocalDataSource>(
  (ref) => SearchLocalDataSourceImpl(ref.watch(marketCacheProvider)),
);

final searchRepositoryProvider = Provider<SearchRepository>(
  (ref) => SearchRepositoryImpl(
    remote: ref.watch(searchRemoteDataSourceProvider),
    local: ref.watch(searchLocalDataSourceProvider),
    networkInfo: ref.watch(networkInfoProvider),
  ),
);

final searchCoinsUseCaseProvider = Provider<SearchCoins>(
  (ref) => SearchCoins(ref.watch(searchRepositoryProvider)),
);
