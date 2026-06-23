import 'package:crypto_tracker_app/features/home/data/dto/trending_api_response_dto.dart';
import 'package:crypto_tracker_app/features/home/domain/entity/trending_coin.dart';

/// Slim DTO persisted in cache and mapped to [TrendingCoin] for the carousel.
///
/// [fromApiItem] delegates to [TrendingCoinItemDto]; [toJson]/[fromJson] use a
/// flat cache format decoupled from the upstream API envelope.
class TrendingCoinDto {
  const TrendingCoinDto({
    required this.id,
    required this.name,
    required this.symbol,
    required this.thumb,
    required this.marketCapRank,
    required this.priceChangePercentage24h,
    this.sparklineUrl = '',
  });

  final String id;
  final String name;
  final String symbol;
  final String thumb;
  final int marketCapRank;
  final double priceChangePercentage24h;
  final String sparklineUrl;

  static double _d(Object? v) => (v as num?)?.toDouble() ?? 0;
  static int _i(Object? v) => (v as num?)?.toInt() ?? 0;

  factory TrendingCoinDto.fromApiItem(Map<String, dynamic> item) =>
      TrendingCoinDto.fromItem(TrendingCoinItemDto.fromJson(item));

  factory TrendingCoinDto.fromItem(TrendingCoinItemDto item) => TrendingCoinDto(
    id: item.id,
    name: item.name,
    symbol: item.symbol,
    thumb: item.displayImage,
    marketCapRank: item.marketCapRank,
    priceChangePercentage24h: item.priceChangePercentage24hUsd,
    sparklineUrl: item.data?.sparkline ?? '',
  );

  factory TrendingCoinDto.fromJson(Map<String, dynamic> json) =>
      TrendingCoinDto(
        id: json['id'] as String? ?? '',
        name: json['name'] as String? ?? '',
        symbol: json['symbol'] as String? ?? '',
        thumb: json['thumb'] as String? ?? '',
        marketCapRank: _i(json['market_cap_rank']),
        priceChangePercentage24h: _d(json['price_change_percentage_24h']),
        sparklineUrl: json['sparkline_url'] as String? ?? '',
      );

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'symbol': symbol,
    'thumb': thumb,
    'market_cap_rank': marketCapRank,
    'price_change_percentage_24h': priceChangePercentage24h,
    'sparkline_url': sparklineUrl,
  };

  TrendingCoin toEntity() => TrendingCoin(
    id: id,
    name: name,
    symbol: symbol,
    thumb: thumb,
    marketCapRank: marketCapRank,
    priceChangePercentage24h: priceChangePercentage24h,
    sparklineUrl: sparklineUrl,
  );
}
