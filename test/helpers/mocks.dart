import 'package:crypto_tracker_app/core/network/network_info.dart';
import 'package:crypto_tracker_app/features/coin_detail/data/datasource/coin_detail_local_datasource.dart';
import 'package:crypto_tracker_app/features/coin_detail/data/datasource/coin_detail_remote_datasource.dart';
import 'package:crypto_tracker_app/features/coin_detail/domain/repository/coin_detail_repository.dart';
import 'package:crypto_tracker_app/features/coin_detail/domain/usecase/get_coin_detail.dart';
import 'package:crypto_tracker_app/features/favorites/domain/repository/favorites_repository.dart';
import 'package:crypto_tracker_app/features/home/data/datasource/market_local_datasource.dart';
import 'package:crypto_tracker_app/features/home/data/datasource/market_remote_datasource.dart';
import 'package:crypto_tracker_app/features/home/domain/repository/market_repository.dart';
import 'package:crypto_tracker_app/features/home/domain/usecase/get_market_coins.dart';
import 'package:crypto_tracker_app/features/home/domain/usecase/get_market_coins_by_ids.dart';
import 'package:crypto_tracker_app/features/search/data/datasource/search_local_datasource.dart';
import 'package:crypto_tracker_app/features/search/data/datasource/search_remote_datasource.dart';
import 'package:crypto_tracker_app/features/search/domain/repository/search_repository.dart';
import 'package:crypto_tracker_app/features/search/domain/usecase/search_coins.dart';
import 'package:mocktail/mocktail.dart';

class MockMarketRepository extends Mock implements MarketRepository {}

class MockMarketRemoteDataSource extends Mock
    implements MarketRemoteDataSource {}

class MockMarketLocalDataSource extends Mock implements MarketLocalDataSource {}

class MockSearchRepository extends Mock implements SearchRepository {}

class MockSearchRemoteDataSource extends Mock
    implements SearchRemoteDataSource {}

class MockSearchLocalDataSource extends Mock implements SearchLocalDataSource {}

class MockNetworkInfo extends Mock implements NetworkInfo {}

class MockGetMarketCoins extends Mock implements GetMarketCoins {}

class MockGetMarketCoinsByIds extends Mock implements GetMarketCoinsByIds {}

class MockSearchCoins extends Mock implements SearchCoins {}

class MockCoinDetailRepository extends Mock implements CoinDetailRepository {}

class MockCoinDetailRemoteDataSource extends Mock
    implements CoinDetailRemoteDataSource {}

class MockCoinDetailLocalDataSource extends Mock
    implements CoinDetailLocalDataSource {}

class MockGetCoinDetail extends Mock implements GetCoinDetail {}

class MockFavoritesRepository extends Mock implements FavoritesRepository {}

/// Registers fallback values for argument matchers (`any()`) on custom types.
/// Call once from a test's `setUpAll`.
void registerCommonFallbacks() {
  registerFallbackValue(const MarketPageParams(page: 1, perPage: 20));
  registerFallbackValue(const MarketCoinsByIdsParams(ids: ['bitcoin']));
  registerFallbackValue(const SearchCoinsParams(query: 'btc'));
  registerFallbackValue(const CoinDetailParams(coinId: 'bitcoin'));
  registerFallbackValue(Duration.zero);
}
