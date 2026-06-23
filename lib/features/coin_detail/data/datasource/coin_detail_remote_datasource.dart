import 'package:dio/dio.dart';

import 'package:crypto_tracker_app/core/network/dio_exception_mapper.dart';
import 'package:crypto_tracker_app/features/coin_detail/data/dto/coin_detail_dto.dart';

abstract interface class CoinDetailRemoteDataSource {
  Future<CoinDetailDto> fetchCoinDetail(String coinId);
}

class CoinDetailRemoteDataSourceImpl implements CoinDetailRemoteDataSource {
  const CoinDetailRemoteDataSourceImpl(this._dio);

  final Dio _dio;

  @override
  Future<CoinDetailDto> fetchCoinDetail(String coinId) async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        '/coins/$coinId',
        queryParameters: const <String, dynamic>{
          'localization': false,
          'tickers': false,
          'market_data': true,
          'community_data': false,
          'developer_data': false,
          'sparkline': false,
        },
      );
      return CoinDetailDto.fromApi(response.data ?? const {});
    } on DioException catch (e) {
      throw mapDioException(e);
    }
  }
}
