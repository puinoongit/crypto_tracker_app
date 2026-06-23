import 'package:crypto_tracker_app/core/cache/cache_store.dart';
import 'package:crypto_tracker_app/features/home/data/dto/coin_market_dto.dart';

/// Persists search results, session query, and recent-search history.
abstract interface class SearchLocalDataSource {
  Future<void> cacheSearchResults(String query, List<CoinMarketDto> coins);

  CachedData<List<CoinMarketDto>>? readSearchResults(String query);

  Future<void> saveLastSearchQuery(String query);

  String? readLastSearchQuery();

  Future<void> clearLastSearchQuery();

  List<String> readSearchHistory();

  Future<void> addSearchHistoryEntry(String query);

  Future<void> clearSearchHistory();
}

class SearchLocalDataSourceImpl implements SearchLocalDataSource {
  const SearchLocalDataSourceImpl(this._cache);

  final CacheStore _cache;

  static const _lastSearchQueryKey = 'search_last_query';
  static const _searchHistoryKey = 'search_history';
  static const maxSearchHistoryEntries = 10;

  String _searchKey(String query) => 'search_${query.trim().toLowerCase()}';

  @override
  Future<void> cacheSearchResults(String query, List<CoinMarketDto> coins) {
    final json = coins.map((c) => c.toJson()).toList();
    return _cache.write(_searchKey(query), json);
  }

  @override
  CachedData<List<CoinMarketDto>>? readSearchResults(String query) {
    final entry = _cache.readList(_searchKey(query));
    if (entry == null) return null;
    final coins = entry.data
        .map((e) => CoinMarketDto.fromJson((e as Map).cast<String, dynamic>()))
        .toList(growable: false);
    return CachedData(data: coins, savedAt: entry.savedAt);
  }

  @override
  Future<void> saveLastSearchQuery(String query) {
    final trimmed = query.trim();
    if (trimmed.isEmpty) return clearLastSearchQuery();
    return _cache.write(_lastSearchQueryKey, trimmed);
  }

  @override
  String? readLastSearchQuery() {
    final entry = _cache.read(_lastSearchQueryKey);
    final value = entry?.data;
    return value is String && value.isNotEmpty ? value : null;
  }

  @override
  Future<void> clearLastSearchQuery() => _cache.delete(_lastSearchQueryKey);

  @override
  List<String> readSearchHistory() {
    final entry = _cache.readList(_searchHistoryKey);
    if (entry == null) return const [];
    return entry.data
        .whereType<String>()
        .map((q) => q.trim())
        .where((q) => q.isNotEmpty)
        .toList(growable: false);
  }

  @override
  Future<void> addSearchHistoryEntry(String query) {
    final trimmed = query.trim();
    if (trimmed.isEmpty) return Future.value();

    final lower = trimmed.toLowerCase();
    final updated = [
      trimmed,
      ...readSearchHistory().where((q) => q.toLowerCase() != lower),
    ].take(maxSearchHistoryEntries).toList(growable: false);

    return _cache.write(_searchHistoryKey, updated);
  }

  @override
  Future<void> clearSearchHistory() => _cache.delete(_searchHistoryKey);
}
