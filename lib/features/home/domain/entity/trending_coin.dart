import 'package:equatable/equatable.dart';

/// A coin in the "Trending · 24h" horizontal carousel.
class TrendingCoin extends Equatable {
  const TrendingCoin({
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

  /// CoinGecko-hosted 7d sparkline (SVG URL from `/search/trending`).
  final String sparklineUrl;

  bool get isPriceUp => priceChangePercentage24h >= 0;
  bool get hasSparkline => sparklineUrl.isNotEmpty;

  @override
  List<Object?> get props => [
    id,
    name,
    symbol,
    thumb,
    marketCapRank,
    priceChangePercentage24h,
    sparklineUrl,
  ];
}
