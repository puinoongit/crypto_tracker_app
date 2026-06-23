import 'package:crypto_tracker_app/core/cache/cache_store.dart';
import 'package:crypto_tracker_app/features/coin_detail/data/dto/coin_detail_dto.dart';

abstract interface class CoinDetailLocalDataSource {
  Future<void> cache(CoinDetailDto detail);
  CachedData<CoinDetailDto>? read(String coinId);
}

class CoinDetailLocalDataSourceImpl implements CoinDetailLocalDataSource {
  const CoinDetailLocalDataSourceImpl(this._cache);

  final CacheStore _cache;

  @override
  Future<void> cache(CoinDetailDto detail) =>
      _cache.write(detail.id, detail.toJson());

  @override
  CachedData<CoinDetailDto>? read(String coinId) {
    final entry = _cache.readObject(coinId);
    if (entry == null) return null;
    return CachedData(
      data: CoinDetailDto.fromJson(entry.data),
      savedAt: entry.savedAt,
    );
  }
}
