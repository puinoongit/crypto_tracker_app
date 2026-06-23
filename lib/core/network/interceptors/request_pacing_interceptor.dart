import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import 'package:crypto_tracker_app/core/config/api_config.dart';

/// Serializes outbound requests with a minimum gap to avoid bursting past
/// CoinGecko's free-tier rate limit (especially on cold start).
class RequestPacingInterceptor extends Interceptor {
  static DateTime? _lastStartedAt;
  static Future<void> _tail = Future<void>.value();

  @visibleForTesting
  static void resetForTest() {
    _lastStartedAt = null;
    _tail = Future<void>.value();
  }

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    _tail = _tail.then((_) async {
      final last = _lastStartedAt;
      if (last != null) {
        final elapsed = DateTime.now().difference(last);
        const gap = ApiConfig.minRequestInterval;
        if (elapsed < gap) {
          await Future<void>.delayed(gap - elapsed);
        }
      }
      _lastStartedAt = DateTime.now();
    });

    _tail.then((_) {
      handler.next(options);
    });
  }
}
