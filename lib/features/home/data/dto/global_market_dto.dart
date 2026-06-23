import 'package:crypto_tracker_app/features/home/domain/entity/global_market.dart';
import 'global_api_response_dto.dart';

/// Slim DTO persisted in cache and mapped to [GlobalMarket] for the header card.
///
/// [fromApi] delegates to [GlobalApiResponseDto]; [toJson]/[fromJson] use a flat
/// cache format decoupled from the upstream API envelope.
class GlobalMarketDto {
  const GlobalMarketDto({
    required this.totalMarketCap,
    required this.marketCapChangePercentage24h,
    required this.totalVolume,
  });

  final double totalMarketCap;
  final double marketCapChangePercentage24h;
  final double totalVolume;

  static double _d(Object? v) => (v as num?)?.toDouble() ?? 0;

  factory GlobalMarketDto.fromApi(Map<String, dynamic> json) {
    final data = GlobalApiResponseDto.fromJson(json).data;
    return GlobalMarketDto(
      totalMarketCap: data.currency(data.totalMarketCap),
      totalVolume: data.currency(data.totalVolume),
      marketCapChangePercentage24h: data.marketCapChangePercentage24hUsd,
    );
  }

  factory GlobalMarketDto.fromJson(Map<String, dynamic> json) =>
      GlobalMarketDto(
        totalMarketCap: _d(json['total_market_cap']),
        totalVolume: _d(json['total_volume']),
        marketCapChangePercentage24h: _d(
          json['market_cap_change_percentage_24h'],
        ),
      );

  Map<String, dynamic> toJson() => {
    'total_market_cap': totalMarketCap,
    'total_volume': totalVolume,
    'market_cap_change_percentage_24h': marketCapChangePercentage24h,
  };

  GlobalMarket toEntity() => GlobalMarket(
    totalMarketCap: totalMarketCap,
    marketCapChangePercentage24h: marketCapChangePercentage24h,
    totalVolume: totalVolume,
  );
}
