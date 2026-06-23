import 'package:crypto_tracker_app/core/config/api_config.dart';
import 'package:crypto_tracker_app/core/network/interceptors/request_pacing_interceptor.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockRequestHandler extends Mock implements RequestInterceptorHandler {}

void main() {
  late RequestPacingInterceptor interceptor;

  setUpAll(() {
    registerFallbackValue(RequestOptions(path: '/'));
  });

  setUp(() {
    RequestPacingInterceptor.resetForTest();
    interceptor = RequestPacingInterceptor();
  });

  test('first request proceeds without delay', () async {
    final handler = MockRequestHandler();
    when(() => handler.next(any())).thenReturn(null);

    interceptor.onRequest(RequestOptions(path: '/a'), handler);
    await pumpEventQueue();

    verify(() => handler.next(any())).called(1);
  });

  test('second request waits at least minRequestInterval', () async {
    final first = MockRequestHandler();
    final second = MockRequestHandler();
    when(() => first.next(any())).thenReturn(null);
    when(() => second.next(any())).thenReturn(null);

    interceptor.onRequest(RequestOptions(path: '/a'), first);
    await pumpEventQueue();
    verify(() => first.next(any())).called(1);

    final gapStart = DateTime.now();
    interceptor.onRequest(RequestOptions(path: '/b'), second);
    await Future<void>.delayed(ApiConfig.minRequestInterval);
    await pumpEventQueue();

    verify(() => second.next(any())).called(1);
    expect(
      DateTime.now().difference(gapStart),
      greaterThanOrEqualTo(
        ApiConfig.minRequestInterval - const Duration(milliseconds: 30),
      ),
    );
  });
}
