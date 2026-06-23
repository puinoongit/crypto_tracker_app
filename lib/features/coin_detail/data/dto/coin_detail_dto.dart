import 'package:crypto_tracker_app/features/coin_detail/domain/entity/coin_detail.dart';

/// Slim DTO persisted in cache and mapped to [CoinDetail] for the detail screen.
///
/// Two ingestion paths are supported:
///  * [CoinDetailDto.fromApi] parses only the `/coins/{id}` fields the UI uses.
///  * [CoinDetailDto.fromJson] parses our own flat cache format ([toJson]).
///
/// Keeping the cache format flat decouples our storage from the upstream API
/// shape, so an API restructure never invalidates cached data unexpectedly.
class CoinDetailDto {
  const CoinDetailDto({
    required this.id,
    required this.symbol,
    required this.name,
    required this.image,
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
  final String image;
  final double currentPrice;
  final double priceChangePercentage24h;
  final double marketCap;
  final int marketCapRank;
  final double totalVolume;
  final double ath;
  final double athChangePercentage;
  final double atl;
  final double atlChangePercentage;
  final double circulatingSupply;
  final double? maxSupply;
  final String description;

  static double _d(Object? v) => (v as num?)?.toDouble() ?? 0;
  static double? _dn(Object? v) => (v as num?)?.toDouble();
  static int _i(Object? v) => (v as num?)?.toInt() ?? 0;

  static double _usd(Object? node) {
    if (node is! Map) return 0;
    return _d(node['usd']);
  }

  static String _bestImageUrl(Object? image) {
    if (image is! Map) return '';
    final large = image['large'] as String? ?? '';
    if (large.isNotEmpty) return large;
    final small = image['small'] as String? ?? '';
    if (small.isNotEmpty) return small;
    return image['thumb'] as String? ?? '';
  }

  static String _descriptionEn(Object? description) {
    if (description is! Map) return '';
    return description['en']?.toString() ?? '';
  }

  /// Parses only the CoinGecko `/coins/{id}` fields used by the detail screen.
  factory CoinDetailDto.fromApi(Map<String, dynamic> json) {
    final market = json['market_data'];
    final marketData = market is Map<String, dynamic> ? market : null;

    return CoinDetailDto(
      id: json['id'] as String? ?? '',
      symbol: json['symbol'] as String? ?? '',
      name: json['name'] as String? ?? '',
      image: _bestImageUrl(json['image']),
      marketCapRank: _i(json['market_cap_rank']),
      currentPrice: _usd(marketData?['current_price']),
      marketCap: _usd(marketData?['market_cap']),
      totalVolume: _usd(marketData?['total_volume']),
      ath: _usd(marketData?['ath']),
      athChangePercentage: _usd(marketData?['ath_change_percentage']),
      atl: _usd(marketData?['atl']),
      atlChangePercentage: _usd(marketData?['atl_change_percentage']),
      priceChangePercentage24h: _d(marketData?['price_change_percentage_24h']),
      circulatingSupply: _d(marketData?['circulating_supply']),
      maxSupply: _dn(marketData?['max_supply']),
      description: _descriptionEn(json['description']),
    );
  }

  factory CoinDetailDto.fromJson(Map<String, dynamic> json) => CoinDetailDto(
    id: json['id'] as String? ?? '',
    symbol: json['symbol'] as String? ?? '',
    name: json['name'] as String? ?? '',
    image: json['image'] as String? ?? '',
    currentPrice: _d(json['current_price']),
    priceChangePercentage24h: _d(json['price_change_percentage_24h']),
    marketCap: _d(json['market_cap']),
    marketCapRank: _i(json['market_cap_rank']),
    totalVolume: _d(json['total_volume']),
    ath: _d(json['ath']),
    athChangePercentage: _d(json['ath_change_percentage']),
    atl: _d(json['atl']),
    atlChangePercentage: _d(json['atl_change_percentage']),
    circulatingSupply: _d(json['circulating_supply']),
    maxSupply: _dn(json['max_supply']),
    description: json['description'] as String? ?? '',
  );

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
    'ath': ath,
    'ath_change_percentage': athChangePercentage,
    'atl': atl,
    'atl_change_percentage': atlChangePercentage,
    'circulating_supply': circulatingSupply,
    'max_supply': maxSupply,
    'description': description,
  };

  CoinDetail toEntity() => CoinDetail(
    id: id,
    symbol: symbol,
    name: name,
    imageUrl: image,
    currentPrice: currentPrice,
    priceChangePercentage24h: priceChangePercentage24h,
    marketCap: marketCap,
    marketCapRank: marketCapRank,
    totalVolume: totalVolume,
    ath: ath,
    athChangePercentage: athChangePercentage,
    atl: atl,
    atlChangePercentage: atlChangePercentage,
    circulatingSupply: circulatingSupply,
    maxSupply: maxSupply,
    description: description,
  );
}
