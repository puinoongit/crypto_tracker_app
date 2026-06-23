import 'package:crypto_tracker_app/core/error/exceptions.dart';
import 'package:crypto_tracker_app/core/network/dio_exception_mapper.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final options = RequestOptions(path: '/x');

  DioException ex(
    DioExceptionType type, {
    Response<dynamic>? response,
    String? message,
  }) => DioException(
    requestOptions: options,
    type: type,
    response: response,
    message: message,
  );

  group('mapDioException', () {
    test('maps timeouts to TimeoutException', () {
      expect(
        mapDioException(ex(DioExceptionType.connectionTimeout)),
        isA<TimeoutException>(),
      );
      expect(
        mapDioException(ex(DioExceptionType.receiveTimeout)),
        isA<TimeoutException>(),
      );
      expect(
        mapDioException(ex(DioExceptionType.sendTimeout)),
        isA<TimeoutException>(),
      );
    });

    test('maps connectionError to NoInternetException', () {
      expect(
        mapDioException(ex(DioExceptionType.connectionError)),
        isA<NoInternetException>(),
      );
    });

    test('maps badResponse to ServerException carrying the status code', () {
      final result = mapDioException(
        ex(
          DioExceptionType.badResponse,
          response: Response<dynamic>(requestOptions: options, statusCode: 503),
        ),
      );
      expect(result, isA<ServerException>());
      expect((result as ServerException).statusCode, 503);
    });

    test('treats socket-like unknown errors as no internet', () {
      expect(
        mapDioException(
          ex(DioExceptionType.unknown, message: 'SocketException'),
        ),
        isA<NoInternetException>(),
      );
    });

    test('falls back to UnknownException otherwise', () {
      expect(
        mapDioException(ex(DioExceptionType.unknown, message: 'weird')),
        isA<UnknownException>(),
      );
    });
  });
}
