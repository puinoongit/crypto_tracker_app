/// Centralized, immutable networking configuration.
///
/// Keeping these values in one place makes them trivial to override per
/// environment (e.g. a staging base URL) and easy to assert against in tests.
abstract final class ApiConfig {
  static const String baseUrl = 'https://api.coingecko.com/api/v3';

  /// Injected at build time via `--dart-define` or `--dart-define-from-file`.
  ///
  /// Example:
  /// ```bash
  /// flutter run --dart-define=COINGECKO_API_KEY=CG-xxxx
  /// flutter build apk --dart-define-from-file=env.json
  /// ```
  static const String coinGeckoApiKey = String.fromEnvironment(
    'COINGECKO_API_KEY',
  );

  /// `demo` (default) or `pro` — selects the CoinGecko API-key header name.
  static const String coinGeckoApiKeyType = String.fromEnvironment(
    'COINGECKO_API_KEY_TYPE',
    defaultValue: 'demo',
  );

  /// Extra Dio headers when [coinGeckoApiKey] is set; empty otherwise.
  static Map<String, String> get apiKeyHeaders {
    if (coinGeckoApiKey.isEmpty) return const {};

    const headerName = coinGeckoApiKeyType == 'pro'
        ? 'x-cg-pro-api-key'
        : 'x-cg-demo-api-key';
    return {headerName: coinGeckoApiKey};
  }

  static const Duration connectTimeout = Duration(seconds: 15);
  static const Duration receiveTimeout = Duration(seconds: 20);

  /// Number of coins requested per page for the market list.
  static const int pageSize = 20;

  /// Queries shorter than this use client-side filter over loaded pages only.
  static const int searchMinLength = 2;

  /// Foreground polling interval on the Market tab (online, not searching).
  static const Duration foregroundPollInterval = Duration(seconds: 120);

  /// Retry strategy for transient/network failures.
  static const int maxRetries = 3;
  static const Duration retryBaseDelay = Duration(milliseconds: 500);

  /// Fewer retries for 429 — repeating a rate-limited call makes things worse.
  static const int rateLimitMaxRetries = 1;

  /// Minimum spacing between API calls to stay under CoinGecko free-tier limits.
  static const Duration minRequestInterval = Duration(milliseconds: 700);

  /// Backoff base when CoinGecko returns 429 (rate limit).
  static const Duration rateLimitRetryDelay = Duration(seconds: 2);
}
