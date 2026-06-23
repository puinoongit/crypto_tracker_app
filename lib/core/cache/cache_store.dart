import 'dart:convert';

import 'package:hive/hive.dart';

/// A value read back from the cache, tagged with when it was written.
class CachedData<T> {
  const CachedData({required this.data, required this.savedAt});

  final T data;
  final DateTime savedAt;

  /// Whether this entry is older than [ttl]. A `null` [ttl] means it never
  /// expires (used for favorites).
  bool isExpired(Duration? ttl) {
    if (ttl == null) return false;
    return DateTime.now().difference(savedAt) > ttl;
  }
}

/// A thin, typed wrapper around a Hive box that transparently stores a
/// `savedAt` timestamp alongside each value.
///
/// Values are persisted as JSON strings so the cache works for any
/// JSON-serializable payload (maps, lists) without `TypeAdapter`s.
class CacheStore {
  const CacheStore(this._box);

  final Box<String> _box;

  /// Persists [data] under [key], stamping it with the current time.
  Future<void> write(String key, Object? data) {
    final envelope = <String, dynamic>{
      'savedAt': DateTime.now().millisecondsSinceEpoch,
      'data': data,
    };
    return _box.put(key, jsonEncode(envelope));
  }

  /// Reads the raw payload for [key], or `null` if absent/corrupt.
  CachedData<dynamic>? read(String key) {
    final raw = _box.get(key);
    if (raw == null) return null;
    try {
      final envelope = jsonDecode(raw) as Map<String, dynamic>;
      return CachedData<dynamic>(
        data: envelope['data'],
        savedAt: DateTime.fromMillisecondsSinceEpoch(
          envelope['savedAt'] as int,
        ),
      );
    } catch (_) {
      // Corrupt entry — drop it so a fresh fetch can repopulate.
      _box.delete(key);
      return null;
    }
  }

  /// Reads and casts the payload to a JSON object.
  CachedData<Map<String, dynamic>>? readObject(String key) {
    final entry = read(key);
    if (entry == null) return null;
    return CachedData(
      data: (entry.data as Map).cast<String, dynamic>(),
      savedAt: entry.savedAt,
    );
  }

  /// Reads and casts the payload to a JSON list.
  CachedData<List<dynamic>>? readList(String key) {
    final entry = read(key);
    if (entry == null) return null;
    return CachedData(
      data: entry.data as List<dynamic>,
      savedAt: entry.savedAt,
    );
  }

  bool containsKey(String key) => _box.containsKey(key);

  Future<void> delete(String key) => _box.delete(key);

  Iterable<String> get keys => _box.keys.cast<String>();
}
