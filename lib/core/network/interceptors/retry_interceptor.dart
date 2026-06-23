import 'dart:async';

import 'package:dio/dio.dart';

import 'package:crypto_tracker_app/core/config/api_config.dart';

/// Retries transient failures with exponential backoff.
///
/// Only *idempotent* situations are retried: connection/timeout errors and
/// `429`/`5xx` responses. Client errors (4xx other than 429) are never retried
/// because they will not succeed on a second attempt.
///
/// For `429`, waits longer (and honors `Retry-After` when present) to avoid
/// hammering CoinGecko's free-tier rate limit.
class RetryInterceptor extends Interceptor {
  RetryInterceptor({
    required Dio dio,
    required this.maxRetries,
    required this.baseDelay,
  }) : _dio = dio;

  final Dio _dio;
  final int maxRetries;
  final Duration baseDelay;

  int _maxAttempts(DioException err) => err.response?.statusCode == 429
      ? ApiConfig.rateLimitMaxRetries
      : maxRetries;

  static const String _retryCountKey = 'retry_count';

  bool _shouldRetry(DioException err) {
    switch (err.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.connectionError:
        return true;
      case DioExceptionType.badResponse:
        final status = err.response?.statusCode ?? 0;
        return status == 429 || status >= 500;
      case DioExceptionType.cancel:
      case DioExceptionType.badCertificate:
      case DioExceptionType.unknown:
        return false;
    }
  }

  /// Computes delay before the next attempt. Rate limits get a longer backoff.
  static Duration retryDelay(DioException err, int attempt, Duration base) {
    if (err.response?.statusCode == 429) {
      final header = err.response?.headers.value('retry-after');
      if (header != null) {
        final seconds = int.tryParse(header);
        if (seconds != null && seconds > 0) {
          return Duration(seconds: seconds.clamp(1, 60));
        }
      }
      return ApiConfig.rateLimitRetryDelay * (1 << attempt);
    }
    return base * (1 << attempt);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    final attempt = (err.requestOptions.extra[_retryCountKey] as int?) ?? 0;

    if (attempt >= _maxAttempts(err) || !_shouldRetry(err)) {
      handler.next(err);
      return;
    }

    final nextAttempt = attempt + 1;
    final delay = retryDelay(err, attempt, baseDelay);
    await Future<void>.delayed(delay);

    final options = err.requestOptions..extra[_retryCountKey] = nextAttempt;

    try {
      final response = await _dio.fetch<dynamic>(options);
      handler.resolve(response);
    } on DioException catch (e) {
      handler.next(e);
    }
  }
}
