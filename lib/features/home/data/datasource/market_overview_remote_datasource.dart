import 'package:dio/dio.dart';

import 'package:crypto_tracker_app/core/network/dio_exception_mapper.dart';
import 'package:crypto_tracker_app/features/home/data/dto/global_market_dto.dart';
import 'package:crypto_tracker_app/features/home/data/dto/trending_api_response_dto.dart';
import 'package:crypto_tracker_app/features/home/data/dto/trending_coin_dto.dart';

/// Talks to the CoinGecko `/global` and `/search/trending` endpoints.
abstract interface class MarketOverviewRemoteDataSource {
  Future<GlobalMarketDto> fetchGlobalMarket();
  Future<List<TrendingCoinDto>> fetchTrendingCoins();
}

class MarketOverviewRemoteDataSourceImpl
    implements MarketOverviewRemoteDataSource {
  const MarketOverviewRemoteDataSourceImpl(this._dio);

  final Dio _dio;

  @override
  Future<GlobalMarketDto> fetchGlobalMarket() async {
    try {
      final response = await _dio.get<Map<String, dynamic>>('/global');
      return GlobalMarketDto.fromApi(response.data ?? const {});
    } on DioException catch (e) {
      throw mapDioException(e);
    }
  }

  @override
  Future<List<TrendingCoinDto>> fetchTrendingCoins() async {
    try {
      final response = await _dio.get<Map<String, dynamic>>('/search/trending');
      final trending = TrendingApiResponseDto.fromJson(
        response.data ?? const {},
      );
      return trending.coins
          .map((entry) => TrendingCoinDto.fromItem(entry.item))
          .toList(growable: false);
    } on DioException catch (e) {
      throw mapDioException(e);
    }
  }
}
