import 'package:crypto_tracker_app/core/cache/cache_policy.dart';
import 'package:crypto_tracker_app/core/config/api_config.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('CachePolicy', () {
    test('marketPollTtl matches foreground poll interval', () {
      expect(CachePolicy.marketPollTtl, ApiConfig.foregroundPollInterval);
    });

    test('marketPollTtl is shorter than default market list TTL', () {
      expect(CachePolicy.marketPollTtl, lessThan(CachePolicy.marketTtl));
    });
  });
}
