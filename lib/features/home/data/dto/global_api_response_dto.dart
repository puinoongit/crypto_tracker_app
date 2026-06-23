/// DTOs mirroring the CoinGecko [`/global`](https://api.coingecko.com/api/v3/global)
/// response shape (`{ "data": { ... } }`).
///
/// The UI only needs a handful of USD fields via [GlobalMarketDto]; the full
/// model is kept here so parsing is explicit, testable, and easy to extend.
class GlobalApiResponseDto {
  const GlobalApiResponseDto({required this.data});

  final GlobalDataDto data;

  factory GlobalApiResponseDto.fromJson(Map<String, dynamic> json) {
    final raw = json['data'];
    return GlobalApiResponseDto(
      data: raw is Map<String, dynamic>
          ? GlobalDataDto.fromJson(raw)
          : GlobalDataDto.empty(),
    );
  }
}

/// The `data` object inside a `/global` response.
class GlobalDataDto {
  const GlobalDataDto({
    required this.activeCryptocurrencies,
    required this.upcomingIcos,
    required this.ongoingIcos,
    required this.endedIcos,
    required this.markets,
    required this.totalMarketCap,
    required this.totalVolume,
    required this.marketCapPercentage,
    required this.marketCapChangePercentage24hUsd,
    required this.volumeChangePercentage24hUsd,
    required this.updatedAt,
  });

  final int activeCryptocurrencies;
  final int upcomingIcos;
  final int ongoingIcos;
  final int endedIcos;
  final int markets;

  /// Multi-currency totals keyed by currency code (e.g. `usd`, `btc`, `thb`).
  final Map<String, double> totalMarketCap;
  final Map<String, double> totalVolume;

  /// Dominance share per asset id (e.g. `btc` → 56.43).
  final Map<String, double> marketCapPercentage;

  final double marketCapChangePercentage24hUsd;
  final double volumeChangePercentage24hUsd;

  /// Unix timestamp (seconds).
  final int updatedAt;

  factory GlobalDataDto.empty() => const GlobalDataDto(
    activeCryptocurrencies: 0,
    upcomingIcos: 0,
    ongoingIcos: 0,
    endedIcos: 0,
    markets: 0,
    totalMarketCap: {},
    totalVolume: {},
    marketCapPercentage: {},
    marketCapChangePercentage24hUsd: 0,
    volumeChangePercentage24hUsd: 0,
    updatedAt: 0,
  );

  factory GlobalDataDto.fromJson(Map<String, dynamic> json) {
    return GlobalDataDto(
      activeCryptocurrencies: _i(json['active_cryptocurrencies']),
      upcomingIcos: _i(json['upcoming_icos']),
      ongoingIcos: _i(json['ongoing_icos']),
      endedIcos: _i(json['ended_icos']),
      markets: _i(json['markets']),
      totalMarketCap: _currencyMap(json['total_market_cap']),
      totalVolume: _currencyMap(json['total_volume']),
      marketCapPercentage: _currencyMap(json['market_cap_percentage']),
      marketCapChangePercentage24hUsd: _d(
        json['market_cap_change_percentage_24h_usd'],
      ),
      volumeChangePercentage24hUsd: _d(
        json['volume_change_percentage_24h_usd'],
      ),
      updatedAt: _i(json['updated_at']),
    );
  }

  /// Reads a value from a multi-currency map; defaults to `usd`.
  double currency(Map<String, double> values, [String code = 'usd']) =>
      values[code] ?? 0;

  static double _d(Object? v) => (v as num?)?.toDouble() ?? 0;
  static int _i(Object? v) => (v as num?)?.toInt() ?? 0;

  static Map<String, double> _currencyMap(Object? node) {
    if (node is! Map) return const {};

    return Map<String, double>.unmodifiable(
      node.map((key, value) => MapEntry(key.toString(), _d(value))),
    );
  }
}
