import 'package:dio/dio.dart';

import 'package:crypto_tracker_app/core/config/api_config.dart';
import 'interceptors/logging_interceptor.dart';
import 'interceptors/request_pacing_interceptor.dart';
import 'interceptors/retry_interceptor.dart';

/// Factory for a fully-configured [Dio] instance.
///
/// Centralizing construction here guarantees every part of the app shares the
/// same timeouts, base URL, and interceptor pipeline. The order of interceptors
/// matters: logging runs first (to observe everything), retry last (so it can
/// re-drive the request after a transient error).
abstract final class DioClient {
  static Dio create({required bool enableLogging}) {
    final dio = Dio(
      BaseOptions(
        baseUrl: ApiConfig.baseUrl,
        connectTimeout: ApiConfig.connectTimeout,
        receiveTimeout: ApiConfig.receiveTimeout,
        headers: {'Accept': 'application/json', ...ApiConfig.apiKeyHeaders},
      ),
    );

    dio.interceptors.addAll([
      LoggingInterceptor(enabled: enableLogging),
      RequestPacingInterceptor(),
      RetryInterceptor(
        dio: dio,
        maxRetries: ApiConfig.maxRetries,
        baseDelay: ApiConfig.retryBaseDelay,
      ),
    ]);

    return dio;
  }
}
