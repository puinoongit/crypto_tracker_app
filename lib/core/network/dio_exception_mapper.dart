import 'package:dio/dio.dart';

import 'package:crypto_tracker_app/core/error/exceptions.dart';

/// Translates a [DioException] into one of our internal data-layer exceptions.
///
/// This is the single choke point where raw Dio errors are classified, so every
/// remote data source maps errors consistently.
Exception mapDioException(DioException error) {
  switch (error.type) {
    case DioExceptionType.connectionTimeout:
    case DioExceptionType.sendTimeout:
    case DioExceptionType.receiveTimeout:
      return const TimeoutException();
    case DioExceptionType.connectionError:
      return const NoInternetException();
    case DioExceptionType.badResponse:
      return ServerException(
        statusCode: error.response?.statusCode,
        message: error.message,
      );
    case DioExceptionType.cancel:
    case DioExceptionType.badCertificate:
    case DioExceptionType.unknown:
      // A socket-level failure often surfaces as `unknown`; treat the common
      // "no address associated with hostname" case as a connectivity problem.
      final message = error.message?.toLowerCase() ?? '';
      if (message.contains('socket') || message.contains('network')) {
        return const NoInternetException();
      }
      return UnknownException(error.message);
  }
}
