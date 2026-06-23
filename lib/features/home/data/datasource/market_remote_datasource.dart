import 'package:dio/dio.dart';

import 'package:crypto_tracker_app/core/network/dio_exception_mapper.dart';
import 'package:crypto_tracker_app/features/home/data/dto/coin_market_dto.dart';
import 'package:crypto_tracker_app/features/home/data/dto/coin_market_item_dto.dart';

/// Talks to the CoinGecko `/coins/markets` endpoint.
///
/// Responsibility is strictly transport + parsing: it returns DTOs or throws a
/// classified data-layer exception (via [mapDioException]). It knows nothing
/// about caching or domain entities.
abstract interface class MarketRemoteDataSource {
  Future<List<CoinMarketDto>> fetchMarketCoins({
    required int page,
    required int perPage,
  });

  Future<List<CoinMarketDto>> fetchMarketCoinsByIds({
    required List<String> ids,
  });
}

class MarketRemoteDataSourceImpl implements MarketRemoteDataSource {
  const MarketRemoteDataSourceImpl(this._dio);

  final Dio _dio;

  @override
  Future<List<CoinMarketDto>> fetchMarketCoins({
    required int page,
    required int perPage,
  }) async {
    try {
      final response = await _dio.get<List<dynamic>>(
        '/coins/markets',
        queryParameters: <String, dynamic>{
          'vs_currency': 'usd',
          'order': 'market_cap_desc',
          'per_page': perPage,
          'page': page,
          'sparkline': true,
          'price_change_percentage': '24h',
        },
      );

      final data = response.data ?? const [];
      return CoinMarketsApiResponse.fromJsonList(
        data,
      ).items.map(CoinMarketDto.fromApiItem).toList(growable: false);
    } on DioException catch (e) {
      throw mapDioException(e);
    }
  }

  @override
  Future<List<CoinMarketDto>> fetchMarketCoinsByIds({
    required List<String> ids,
  }) async {
    if (ids.isEmpty) return const [];

    try {
      final response = await _dio.get<List<dynamic>>(
        '/coins/markets',
        queryParameters: <String, dynamic>{
          'vs_currency': 'usd',
          'ids': ids.join(','),
          'order': 'market_cap_desc',
          'sparkline': true,
          'price_change_percentage': '24h',
        },
      );

      final data = response.data ?? const [];
      return CoinMarketsApiResponse.fromJsonList(
        data,
      ).items.map(CoinMarketDto.fromApiItem).toList(growable: false);
    } on DioException catch (e) {
      throw mapDioException(e);
    }
  }
}
