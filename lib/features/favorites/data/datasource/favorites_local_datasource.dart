import 'package:crypto_tracker_app/core/cache/cache_store.dart';

/// Local persistence for favorite coin ids. Each id is stored under its own
/// key with an envelope timestamp used only for ordering (newest first).
abstract interface class FavoritesLocalDataSource {
  List<String> readAllIds();
  bool contains(String coinId);
  Future<void> put(String coinId);
  Future<void> delete(String coinId);
}

class FavoritesLocalDataSourceImpl implements FavoritesLocalDataSource {
  const FavoritesLocalDataSourceImpl(this._cache);

  final CacheStore _cache;

  @override
  bool contains(String coinId) => _cache.containsKey(coinId);

  @override
  Future<void> put(String coinId) =>
      _cache.write(coinId, const <String, dynamic>{});

  @override
  Future<void> delete(String coinId) => _cache.delete(coinId);

  @override
  List<String> readAllIds() {
    final entries =
        _cache.keys
            .map((key) {
              final entry = _cache.read(key);
              if (entry == null) return null;
              return (id: key, at: entry.savedAt);
            })
            .whereType<({String id, DateTime at})>()
            .toList()
          ..sort((a, b) => b.at.compareTo(a.at));
    return entries.map((e) => e.id).toList(growable: false);
  }
}
