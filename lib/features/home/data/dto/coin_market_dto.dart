import 'package:crypto_tracker_app/features/home/domain/entity/coin.dart';
import 'package:crypto_tracker_app/core/utils/sparkline_sampling.dart';
import 'coin_market_item_dto.dart';

/// Slim DTO persisted in cache and mapped to [Coin] for the market list.
///
/// [fromApiItem] delegates to [CoinMarketItemDto]; [toJson]/[fromJson] use a flat
/// cache format decoupled from the full upstream payload.
class CoinMarketDto {
  const CoinMarketDto({
    required this.id,
    required this.symbol,
    required this.name,
    required this.image,
    required this.currentPrice,
    required this.priceChangePercentage24h,
    required this.marketCap,
    required this.marketCapRank,
    required this.totalVolume,
    this.sparklinePrices = const [],
  });

  final String id;
  final String symbol;
  final String name;
  final String image;
  final double currentPrice;
  final double priceChangePercentage24h;
  final double marketCap;
  final int marketCapRank;
  final double totalVolume;
  final List<double> sparklinePrices;

  factory CoinMarketDto.fromApiItem(CoinMarketItemDto item) => CoinMarketDto(
    id: item.id,
    symbol: item.symbol,
    name: item.name,
    image: item.image,
    currentPrice: item.currentPrice,
    priceChangePercentage24h: item.priceChangePercentage24h,
    marketCap: item.marketCap,
    marketCapRank: item.marketCapRank,
    totalVolume: item.totalVolume,
    sparklinePrices: sampleSparklinePrices(item.sparklineIn7d.prices),
  );

  static double _toDouble(Object? v) => (v as num?)?.toDouble() ?? 0;
  static int _toInt(Object? v) => (v as num?)?.toInt() ?? 0;

  static List<double> _parseSparklinePrices(Map<String, dynamic> json) {
    final sparkline = json['sparkline_in_7d'];
    if (sparkline is! Map) return const [];

    final raw = sparkline['price'];
    if (raw is! List) return const [];

    return sampleSparklinePrices(
      raw.whereType<num>().map((v) => v.toDouble()).toList(growable: false),
    );
  }

  /// Parses the flat cache envelope written by [toJson].
  factory CoinMarketDto.fromJson(Map<String, dynamic> json) {
    return CoinMarketDto(
      id: json['id'] as String? ?? '',
      symbol: json['symbol'] as String? ?? '',
      name: json['name'] as String? ?? '',
      image: json['image'] as String? ?? '',
      currentPrice: _toDouble(json['current_price']),
      priceChangePercentage24h: _toDouble(json['price_change_percentage_24h']),
      marketCap: _toDouble(json['market_cap']),
      marketCapRank: _toInt(json['market_cap_rank']),
      totalVolume: _toDouble(json['total_volume']),
      sparklinePrices: _parseSparklinePrices(json),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'symbol': symbol,
    'name': name,
    'image': image,
    'current_price': currentPrice,
    'price_change_percentage_24h': priceChangePercentage24h,
    'market_cap': marketCap,
    'market_cap_rank': marketCapRank,
    'total_volume': totalVolume,
    'sparkline_in_7d': {'price': sparklinePrices},
  };

  Coin toEntity() => Coin(
    id: id,
    symbol: symbol,
    name: name,
    imageUrl: image,
    currentPrice: currentPrice,
    priceChangePercentage24h: priceChangePercentage24h,
    marketCap: marketCap,
    marketCapRank: marketCapRank,
    totalVolume: totalVolume,
    sparklinePrices: sparklinePrices,
  );
}
