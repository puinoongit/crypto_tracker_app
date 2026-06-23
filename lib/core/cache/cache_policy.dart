import 'package:crypto_tracker_app/core/config/api_config.dart';

/// Time-to-live policy for each cached resource.
///
/// Centralized so the expiration rules live in exactly one place:
///  * market list  → 10 minutes (pagination + offline)
///  * market poll  → same as [ApiConfig.foregroundPollInterval] (live prices)
///  * coin detail  → 30 minutes
///  * favorites    → never expire
abstract final class CachePolicy {
  static const Duration marketTtl = Duration(minutes: 10);

  /// How long page-1 prices are considered fresh enough for foreground polling.
  /// Shorter than [marketTtl] so polls can update prices without bypassing cache.
  static Duration get marketPollTtl => ApiConfig.foregroundPollInterval;

  static const Duration coinDetailTtl = Duration(minutes: 30);

  /// Server search results — short TTL to balance freshness and rate limits.
  static const Duration searchTtl = Duration(minutes: 5);

  /// Favorites are user-owned data and must persist indefinitely.
  static const Duration? favoritesTtl = null;
}
