import 'package:equatable/equatable.dart';

/// Rich, single-coin domain entity backing the detail screen.
class CoinDetail extends Equatable {
  const CoinDetail({
    required this.id,
    required this.symbol,
    required this.name,
    required this.imageUrl,
    required this.currentPrice,
    required this.priceChangePercentage24h,
    required this.marketCap,
    required this.marketCapRank,
    required this.totalVolume,
    required this.ath,
    required this.athChangePercentage,
    required this.atl,
    required this.atlChangePercentage,
    required this.circulatingSupply,
    required this.maxSupply,
    required this.description,
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

  /// All-time high price and its % distance from the current price.
  final double ath;
  final double athChangePercentage;

  /// All-time low price and its % distance from the current price.
  final double atl;
  final double atlChangePercentage;

  final double circulatingSupply;

  /// `null` means the supply is uncapped (e.g. Ethereum).
  final double? maxSupply;

  final String description;

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
    ath,
    athChangePercentage,
    atl,
    atlChangePercentage,
    circulatingSupply,
    maxSupply,
    description,
  ];
}
