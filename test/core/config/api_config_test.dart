import 'package:crypto_tracker_app/core/config/api_config.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ApiConfig.apiKeyHeaders', () {
    test('is empty when COINGECKO_API_KEY is not set', () {
      expect(ApiConfig.apiKeyHeaders, isEmpty);
    });
  });

  group('rate limiting', () {
    test('foreground poll interval is 120 seconds', () {
      expect(ApiConfig.foregroundPollInterval, const Duration(seconds: 120));
    });

    test('request pacing enforces a minimum gap between calls', () {
      expect(ApiConfig.minRequestInterval, const Duration(milliseconds: 700));
    });

    test('429 responses retry at most once', () {
      expect(ApiConfig.rateLimitMaxRetries, 1);
    });
  });
}
