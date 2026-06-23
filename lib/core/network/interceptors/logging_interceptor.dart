import 'dart:developer' as developer;

import 'package:dio/dio.dart';

/// Logs request/response/error metadata to the dev console.
///
/// Only active in debug builds (guarded by [enabled]) so production builds stay
/// silent and avoid leaking request details. Uses `dart:developer` rather than
/// `print` so output is structured and respects the `avoid_print` lint.
class LoggingInterceptor extends Interceptor {
  const LoggingInterceptor({this.enabled = true});

  final bool enabled;

  void _log(String message) {
    if (enabled) developer.log(message, name: 'HTTP');
  }

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    _log('→ ${options.method} ${options.uri}');
    handler.next(options);
  }

  @override
  void onResponse(
    Response<dynamic> response,
    ResponseInterceptorHandler handler,
  ) {
    _log('← ${response.statusCode} ${response.requestOptions.uri}');
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    _log(
      '✗ ${err.type.name} ${err.requestOptions.uri} '
      '(${err.response?.statusCode ?? 'no response'})',
    );
    handler.next(err);
  }
}
