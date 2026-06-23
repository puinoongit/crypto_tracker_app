import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:crypto_tracker_app/core/providers/core_providers.dart';
import 'package:crypto_tracker_app/features/favorites/data/datasource/favorites_local_datasource.dart';
import 'package:crypto_tracker_app/features/favorites/data/repository/favorites_repository_impl.dart';
import 'package:crypto_tracker_app/features/favorites/domain/repository/favorites_repository.dart';
import 'package:crypto_tracker_app/features/favorites/domain/usecase/get_favorite_ids.dart';
import 'package:crypto_tracker_app/features/favorites/domain/usecase/toggle_favorite.dart';

/// Dependency graph for the Favorites feature.

final favoritesLocalDataSourceProvider = Provider<FavoritesLocalDataSource>(
  (ref) => FavoritesLocalDataSourceImpl(ref.watch(favoritesCacheProvider)),
);

final favoritesRepositoryProvider = Provider<FavoritesRepository>(
  (ref) => FavoritesRepositoryImpl(ref.watch(favoritesLocalDataSourceProvider)),
);

final getFavoriteIdsUseCaseProvider = Provider<GetFavoriteIds>(
  (ref) => GetFavoriteIds(ref.watch(favoritesRepositoryProvider)),
);

final toggleFavoriteUseCaseProvider = Provider<ToggleFavorite>(
  (ref) => ToggleFavorite(ref.watch(favoritesRepositoryProvider)),
);
