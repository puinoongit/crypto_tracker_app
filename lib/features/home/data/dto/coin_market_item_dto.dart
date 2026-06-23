/// DTOs mirroring the CoinGecko [`/coins/markets`](https://api.coingecko.com/api/v3/coins/markets)
/// response — a **top-level JSON array** of coin objects.
///
/// The market list UI only needs a subset via [CoinMarketDto]; the full model
/// lives here for explicit parsing and future features (ATH, supply, ROI, etc.).
class CoinMarketsApiResponse {
  const CoinMarketsApiResponse({required this.items});

  final List<CoinMarketItemDto> items;

  /// Parses the raw Dio `List<dynamic>` from `GET /coins/markets`.
  factory CoinMarketsApiResponse.fromJsonList(List<dynamic> raw) {
    return CoinMarketsApiResponse(
      items: raw
          .whereType<Map<String, dynamic>>()
          .map(CoinMarketItemDto.fromJson)
          .toList(growable: false),
    );
  }
}

/// A single element of the `/coins/markets` array.
class CoinMarketItemDto {
  const CoinMarketItemDto({
    required this.id,
    required this.symbol,
    required this.name,
    required this.image,
    required this.currentPrice,
    required this.marketCap,
    required this.marketCapRank,
    required this.fullyDilutedValuation,
    required this.totalVolume,
    required this.high24h,
    required this.low24h,
    required this.priceChange24h,
    required this.priceChangePercentage24h,
    required this.marketCapChange24h,
    required this.marketCapChangePercentage24h,
    required this.circulatingSupply,
    required this.totalSupply,
    required this.maxSupply,
    required this.ath,
    required this.athChangePercentage,
    required this.athDate,
    required this.atl,
    required this.atlChangePercentage,
    required this.atlDate,
    required this.roi,
    required this.lastUpdated,
    required this.sparklineIn7d,
    required this.priceChangePercentage24hInCurrency,
  });

  final String id;
  final String symbol;
  final String name;
  final String image;
  final double currentPrice;
  final double marketCap;
  final int marketCapRank;
  final double fullyDilutedValuation;
  final double totalVolume;
  final double high24h;
  final double low24h;
  final double priceChange24h;
  final double priceChangePercentage24h;
  final double marketCapChange24h;
  final double marketCapChangePercentage24h;
  final double circulatingSupply;
  final double totalSupply;

  /// `null` when the supply is uncapped.
  final double? maxSupply;

  final double ath;
  final double athChangePercentage;
  final String athDate;
  final double atl;
  final double atlChangePercentage;
  final String atlDate;
  final CoinMarketRoiDto? roi;
  final String lastUpdated;
  final CoinMarketSparklineIn7dDto sparklineIn7d;

  /// Duplicate of [priceChangePercentage24h] returned by CoinGecko when
  /// `price_change_percentage=24h` is requested.
  final double priceChangePercentage24hInCurrency;

  factory CoinMarketItemDto.fromJson(Map<String, dynamic> json) {
    final sparkline = json['sparkline_in_7d'];
    final roi = json['roi'];

    return CoinMarketItemDto(
      id: json['id'] as String? ?? '',
      symbol: json['symbol'] as String? ?? '',
      name: json['name'] as String? ?? '',
      image: json['image'] as String? ?? '',
      currentPrice: _d(json['current_price']),
      marketCap: _d(json['market_cap']),
      marketCapRank: _i(json['market_cap_rank']),
      fullyDilutedValuation: _d(json['fully_diluted_valuation']),
      totalVolume: _d(json['total_volume']),
      high24h: _d(json['high_24h']),
      low24h: _d(json['low_24h']),
      priceChange24h: _d(json['price_change_24h']),
      priceChangePercentage24h: _d(json['price_change_percentage_24h']),
      marketCapChange24h: _d(json['market_cap_change_24h']),
      marketCapChangePercentage24h: _d(
        json['market_cap_change_percentage_24h'],
      ),
      circulatingSupply: _d(json['circulating_supply']),
      totalSupply: _d(json['total_supply']),
      maxSupply: _dn(json['max_supply']),
      ath: _d(json['ath']),
      athChangePercentage: _d(json['ath_change_percentage']),
      athDate: json['ath_date'] as String? ?? '',
      atl: _d(json['atl']),
      atlChangePercentage: _d(json['atl_change_percentage']),
      atlDate: json['atl_date'] as String? ?? '',
      roi: roi is Map<String, dynamic> ? CoinMarketRoiDto.fromJson(roi) : null,
      lastUpdated: json['last_updated'] as String? ?? '',
      sparklineIn7d: sparkline is Map<String, dynamic>
          ? CoinMarketSparklineIn7dDto.fromJson(sparkline)
          : CoinMarketSparklineIn7dDto.empty(),
      priceChangePercentage24hInCurrency: _d(
        json['price_change_percentage_24h_in_currency'],
      ),
    );
  }

  static double _d(Object? v) => (v as num?)?.toDouble() ?? 0;
  static double? _dn(Object? v) => (v as num?)?.toDouble();
  static int _i(Object? v) => (v as num?)?.toInt() ?? 0;
}

/// `{ "price": [ ... ] }` inside a market item when `sparkline=true`.
class CoinMarketSparklineIn7dDto {
  const CoinMarketSparklineIn7dDto({required this.prices});

  final List<double> prices;

  factory CoinMarketSparklineIn7dDto.empty() =>
      const CoinMarketSparklineIn7dDto(prices: []);

  factory CoinMarketSparklineIn7dDto.fromJson(Map<String, dynamic> json) {
    final raw = json['price'];
    if (raw is! List) return CoinMarketSparklineIn7dDto.empty();

    return CoinMarketSparklineIn7dDto(
      prices: raw
          .whereType<num>()
          .map((v) => v.toDouble())
          .toList(growable: false),
    );
  }
}

/// Optional ROI block (e.g. Ethereum's BTC-denominated ROI).
class CoinMarketRoiDto {
  const CoinMarketRoiDto({
    required this.times,
    required this.currency,
    required this.percentage,
  });

  final double times;
  final String currency;
  final double percentage;

  factory CoinMarketRoiDto.fromJson(Map<String, dynamic> json) {
    return CoinMarketRoiDto(
      times: (json['times'] as num?)?.toDouble() ?? 0,
      currency: json['currency'] as String? ?? '',
      percentage: (json['percentage'] as num?)?.toDouble() ?? 0,
    );
  }
}
