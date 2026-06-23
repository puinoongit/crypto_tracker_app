import 'package:dio/dio.dart';

import 'package:crypto_tracker_app/core/network/dio_exception_mapper.dart';
import 'package:crypto_tracker_app/features/home/data/dto/coin_market_dto.dart';
import 'package:crypto_tracker_app/features/home/data/dto/coin_market_item_dto.dart';
import 'package:crypto_tracker_app/features/search/data/dto/search_api_response_dto.dart';

/// CoinGecko transport for search: resolve ids, then hydrate market rows.
abstract interface class SearchRemoteDataSource {
  Future<List<String>> searchCoinIds({required String query});

  Future<List<CoinMarketDto>> fetchMarketCoinsByIds({
    required List<String> ids,
  });
}

class SearchRemoteDataSourceImpl implements SearchRemoteDataSource {
  const SearchRemoteDataSourceImpl(this._dio);

  final Dio _dio;

  @override
  Future<List<String>> searchCoinIds({required String query}) async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        '/search',
        queryParameters: <String, dynamic>{'query': query},
      );

      final data = response.data ?? const <String, dynamic>{};
      return SearchApiResponseDto.fromJson(data).coinIds;
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
