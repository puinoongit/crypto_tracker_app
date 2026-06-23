import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:crypto_tracker_app/core/providers/core_providers.dart';
import 'package:crypto_tracker_app/features/coin_detail/data/datasource/coin_detail_local_datasource.dart';
import 'package:crypto_tracker_app/features/coin_detail/data/datasource/coin_detail_remote_datasource.dart';
import 'package:crypto_tracker_app/features/coin_detail/data/repository/coin_detail_repository_impl.dart';
import 'package:crypto_tracker_app/features/coin_detail/domain/repository/coin_detail_repository.dart';
import 'package:crypto_tracker_app/features/coin_detail/domain/usecase/get_coin_detail.dart';

/// Dependency graph for the Coin Detail feature.

final coinDetailRemoteDataSourceProvider = Provider<CoinDetailRemoteDataSource>(
  (ref) => CoinDetailRemoteDataSourceImpl(ref.watch(dioProvider)),
);

final coinDetailLocalDataSourceProvider = Provider<CoinDetailLocalDataSource>(
  (ref) => CoinDetailLocalDataSourceImpl(ref.watch(coinDetailCacheProvider)),
);

final coinDetailRepositoryProvider = Provider<CoinDetailRepository>(
  (ref) => CoinDetailRepositoryImpl(
    remote: ref.watch(coinDetailRemoteDataSourceProvider),
    local: ref.watch(coinDetailLocalDataSourceProvider),
    networkInfo: ref.watch(networkInfoProvider),
  ),
);

final getCoinDetailUseCaseProvider = Provider<GetCoinDetail>(
  (ref) => GetCoinDetail(ref.watch(coinDetailRepositoryProvider)),
);
