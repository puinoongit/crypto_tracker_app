import 'package:crypto_tracker_app/core/config/api_config.dart';
import 'package:crypto_tracker_app/core/network/interceptors/retry_interceptor.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockDio extends Mock implements Dio {}

class MockHandler extends Mock implements ErrorInterceptorHandler {}

void main() {
  late MockDio dio;
  late RetryInterceptor interceptor;

  setUpAll(() {
    registerFallbackValue(RequestOptions(path: '/'));
    registerFallbackValue(
      DioException(requestOptions: RequestOptions(path: '/')),
    );
    registerFallbackValue(
      Response<dynamic>(requestOptions: RequestOptions(path: '/')),
    );
  });

  setUp(() {
    dio = MockDio();
    interceptor = RetryInterceptor(
      dio: dio,
      maxRetries: 2,
      baseDelay: const Duration(milliseconds: 1),
    );
  });

  DioException error(DioExceptionType type, {int? status}) => DioException(
    requestOptions: RequestOptions(path: '/x'),
    type: type,
    response: status == null
        ? null
        : Response<dynamic>(
            requestOptions: RequestOptions(path: '/x'),
            statusCode: status,
          ),
  );

  test('retries a timeout and resolves on success', () async {
    final handler = MockHandler();
    when(() => dio.fetch<dynamic>(any())).thenAnswer(
      (_) async => Response<dynamic>(
        requestOptions: RequestOptions(path: '/x'),
        data: 'ok',
      ),
    );

    await interceptor.onError(error(DioExceptionType.receiveTimeout), handler);

    verify(() => dio.fetch<dynamic>(any())).called(1);
    verify(() => handler.resolve(any())).called(1);
    verifyNever(() => handler.next(any()));
  });

  test('does not retry a 4xx client error', () async {
    final handler = MockHandler();

    await interceptor.onError(
      error(DioExceptionType.badResponse, status: 404),
      handler,
    );

    verifyNever(() => dio.fetch<dynamic>(any()));
    verify(() => handler.next(any())).called(1);
  });

  test('retries 5xx server errors', () async {
    final handler = MockHandler();
    when(() => dio.fetch<dynamic>(any())).thenAnswer(
      (_) async =>
          Response<dynamic>(requestOptions: RequestOptions(path: '/x')),
    );

    await interceptor.onError(
      error(DioExceptionType.badResponse, status: 500),
      handler,
    );

    verify(() => dio.fetch<dynamic>(any())).called(1);
    verify(() => handler.resolve(any())).called(1);
  });

  test('retries 429 rate-limit responses', () async {
    final handler = MockHandler();
    when(() => dio.fetch<dynamic>(any())).thenAnswer(
      (_) async =>
          Response<dynamic>(requestOptions: RequestOptions(path: '/x')),
    );

    await interceptor.onError(
      error(DioExceptionType.badResponse, status: 429),
      handler,
    );

    verify(() => dio.fetch<dynamic>(any())).called(1);
    verify(() => handler.resolve(any())).called(1);
  });

  test('stops retrying 429 once rateLimitMaxRetries is exhausted', () async {
    final handler = MockHandler();
    final exhausted = error(DioExceptionType.badResponse, status: 429)
      ..requestOptions.extra['retry_count'] = ApiConfig.rateLimitMaxRetries;

    await interceptor.onError(exhausted, handler);

    verifyNever(() => dio.fetch<dynamic>(any()));
    verify(() => handler.next(any())).called(1);
  });

  test('uses Retry-After header for 429 backoff', () {
    final err = error(DioExceptionType.badResponse, status: 429);
    err.response!.headers.set('retry-after', '5');

    final delay = RetryInterceptor.retryDelay(
      err,
      0,
      const Duration(milliseconds: 1),
    );

    expect(delay, const Duration(seconds: 5));
  });

  test('stops retrying once max attempts is reached', () async {
    final handler = MockHandler();
    final exhausted = error(DioExceptionType.connectionError)
      ..requestOptions.extra['retry_count'] = 2;

    await interceptor.onError(exhausted, handler);

    verifyNever(() => dio.fetch<dynamic>(any()));
    verify(() => handler.next(any())).called(1);
  });
}
