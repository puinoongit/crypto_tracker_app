import 'package:equatable/equatable.dart';

/// Global market summary shown in the header card (total market cap, its 24h
/// change, and total 24h volume).
class GlobalMarket extends Equatable {
  const GlobalMarket({
    required this.totalMarketCap,
    required this.marketCapChangePercentage24h,
    required this.totalVolume,
  });

  final double totalMarketCap;
  final double marketCapChangePercentage24h;
  final double totalVolume;

  bool get isMarketUp => marketCapChangePercentage24h >= 0;

  @override
  List<Object?> get props => [
    totalMarketCap,
    marketCapChangePercentage24h,
    totalVolume,
  ];
}
