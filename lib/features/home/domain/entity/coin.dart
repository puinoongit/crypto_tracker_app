import 'package:equatable/equatable.dart';

/// A coin as shown in the market list.
///
/// This is a pure domain entity: no JSON, no framework types. The presentation
/// layer depends only on this, never on the DTO it was built from.
class Coin extends Equatable {
  const Coin({
    required this.id,
    required this.symbol,
    required this.name,
    required this.imageUrl,
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
  final String imageUrl;
  final double currentPrice;
  final double priceChangePercentage24h;
  final double marketCap;
  final int marketCapRank;
  final double totalVolume;

  /// Hourly prices for the last 7 days (from CoinGecko `sparkline_in_7d`).
  final List<double> sparklinePrices;

  bool get isPriceUp => priceChangePercentage24h >= 0;

  @override
  List<Object?> get props => [
    id,
    symbol,
    name,
    imageUrl,
    currentPrice,
    priceChangePercentage24h,
    marketCap,
    marketCapRank,
    totalVolume,
    sparklinePrices,
  ];
}
