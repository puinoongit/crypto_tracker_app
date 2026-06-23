/// DTOs mirroring the CoinGecko [`/search/trending`](https://api.coingecko.com/api/v3/search/trending)
/// response (`coins`, `nfts`, `categories`).
///
/// The carousel UI only needs a subset of the coin fields via [TrendingCoinDto];
/// the full model lives here for explicit parsing and future features.
class TrendingApiResponseDto {
  const TrendingApiResponseDto({
    required this.coins,
    required this.nfts,
    required this.categories,
  });

  final List<TrendingCoinEntryDto> coins;
  final List<TrendingNftDto> nfts;
  final List<TrendingCategoryDto> categories;

  factory TrendingApiResponseDto.fromJson(Map<String, dynamic> json) {
    return TrendingApiResponseDto(
      coins: _list(json['coins'], TrendingCoinEntryDto.fromJson),
      nfts: _list(json['nfts'], TrendingNftDto.fromJson),
      categories: _list(json['categories'], TrendingCategoryDto.fromJson),
    );
  }

  static List<T> _list<T>(
    Object? raw,
    T Function(Map<String, dynamic>) fromJson,
  ) {
    if (raw is! List) return const [];

    return raw
        .whereType<Map<String, dynamic>>()
        .map(fromJson)
        .toList(growable: false);
  }
}

/// `{ "item": { ... } }` wrapper inside the `coins` array.
class TrendingCoinEntryDto {
  const TrendingCoinEntryDto({required this.item});

  final TrendingCoinItemDto item;

  factory TrendingCoinEntryDto.fromJson(Map<String, dynamic> json) {
    final raw = json['item'];
    return TrendingCoinEntryDto(
      item: raw is Map<String, dynamic>
          ? TrendingCoinItemDto.fromJson(raw)
          : TrendingCoinItemDto.empty(),
    );
  }
}

/// Inner `item` object for a trending coin.
class TrendingCoinItemDto {
  const TrendingCoinItemDto({
    required this.id,
    required this.coinId,
    required this.name,
    required this.symbol,
    required this.marketCapRank,
    required this.thumb,
    required this.small,
    required this.large,
    required this.slug,
    required this.priceBtc,
    required this.score,
    required this.data,
  });

  final String id;
  final int coinId;
  final String name;
  final String symbol;
  final int marketCapRank;
  final String thumb;
  final String small;
  final String large;
  final String slug;
  final double priceBtc;
  final int score;
  final TrendingCoinMarketDataDto? data;

  factory TrendingCoinItemDto.empty() => const TrendingCoinItemDto(
    id: '',
    coinId: 0,
    name: '',
    symbol: '',
    marketCapRank: 0,
    thumb: '',
    small: '',
    large: '',
    slug: '',
    priceBtc: 0,
    score: 0,
    data: null,
  );

  factory TrendingCoinItemDto.fromJson(Map<String, dynamic> json) {
    final rawData = json['data'];
    return TrendingCoinItemDto(
      id: json['id'] as String? ?? '',
      coinId: _i(json['coin_id']),
      name: json['name'] as String? ?? '',
      symbol: json['symbol'] as String? ?? '',
      marketCapRank: _i(json['market_cap_rank']),
      thumb: json['thumb'] as String? ?? '',
      small: json['small'] as String? ?? '',
      large: json['large'] as String? ?? '',
      slug: json['slug'] as String? ?? '',
      priceBtc: _d(json['price_btc']),
      score: _i(json['score']),
      data: rawData is Map<String, dynamic>
          ? TrendingCoinMarketDataDto.fromJson(rawData)
          : null,
    );
  }

  /// USD 24h change used by the trending carousel.
  double get priceChangePercentage24hUsd =>
      data?.priceChangePercentage24h['usd'] ?? 0;

  /// Best image URL for list/carousel display.
  String get displayImage =>
      small.isNotEmpty ? small : (thumb.isNotEmpty ? thumb : large);

  static double _d(Object? v) => (v as num?)?.toDouble() ?? 0;
  static int _i(Object? v) => (v as num?)?.toInt() ?? 0;
}

/// The nested `data` block on a trending coin item.
class TrendingCoinMarketDataDto {
  const TrendingCoinMarketDataDto({
    required this.price,
    required this.priceBtc,
    required this.priceChangePercentage24h,
    required this.marketCap,
    required this.marketCapBtc,
    required this.totalVolume,
    required this.totalVolumeBtc,
    required this.sparkline,
    required this.content,
  });

  final double price;

  /// API may return this as a string or number.
  final String priceBtc;
  final Map<String, double> priceChangePercentage24h;

  /// Pre-formatted strings from CoinGecko (e.g. `"$70,894,872"`).
  final String marketCap;
  final String marketCapBtc;
  final String totalVolume;
  final String totalVolumeBtc;
  final String sparkline;
  final TrendingContentDto? content;

  factory TrendingCoinMarketDataDto.fromJson(Map<String, dynamic> json) {
    final rawContent = json['content'];
    return TrendingCoinMarketDataDto(
      price: _d(json['price']),
      priceBtc: _str(json['price_btc']),
      priceChangePercentage24h: _currencyMap(
        json['price_change_percentage_24h'],
      ),
      marketCap: json['market_cap'] as String? ?? '',
      marketCapBtc: json['market_cap_btc'] as String? ?? '',
      totalVolume: json['total_volume'] as String? ?? '',
      totalVolumeBtc: json['total_volume_btc'] as String? ?? '',
      sparkline: json['sparkline'] as String? ?? '',
      content: rawContent is Map<String, dynamic>
          ? TrendingContentDto.fromJson(rawContent)
          : null,
    );
  }

  static double _d(Object? v) => (v as num?)?.toDouble() ?? 0;
  static String _str(Object? v) => v?.toString() ?? '';

  static Map<String, double> _currencyMap(Object? node) {
    if (node is! Map) return const {};

    return Map<String, double>.unmodifiable(
      node.map((key, value) => MapEntry(key.toString(), _d(value))),
    );
  }
}

/// Optional `content` block (`title` + `description`).
class TrendingContentDto {
  const TrendingContentDto({required this.title, required this.description});

  final String title;
  final String description;

  factory TrendingContentDto.fromJson(Map<String, dynamic> json) {
    return TrendingContentDto(
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
    );
  }
}

/// An element of the `nfts` array.
class TrendingNftDto {
  const TrendingNftDto({
    required this.id,
    required this.name,
    required this.symbol,
    required this.thumb,
    required this.nftContractId,
    required this.nativeCurrencySymbol,
    required this.floorPriceInNativeCurrency,
    required this.floorPrice24hPercentageChange,
    required this.data,
  });

  final String id;
  final String name;
  final String symbol;
  final String thumb;
  final int nftContractId;
  final String nativeCurrencySymbol;
  final double floorPriceInNativeCurrency;
  final double floorPrice24hPercentageChange;
  final TrendingNftDataDto? data;

  factory TrendingNftDto.fromJson(Map<String, dynamic> json) {
    final rawData = json['data'];
    return TrendingNftDto(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      symbol: json['symbol'] as String? ?? '',
      thumb: json['thumb'] as String? ?? '',
      nftContractId: _i(json['nft_contract_id']),
      nativeCurrencySymbol: json['native_currency_symbol'] as String? ?? '',
      floorPriceInNativeCurrency: _d(json['floor_price_in_native_currency']),
      floorPrice24hPercentageChange: _d(
        json['floor_price_24h_percentage_change'],
      ),
      data: rawData is Map<String, dynamic>
          ? TrendingNftDataDto.fromJson(rawData)
          : null,
    );
  }

  static double _d(Object? v) => (v as num?)?.toDouble() ?? 0;
  static int _i(Object? v) => (v as num?)?.toInt() ?? 0;
}

/// Nested `data` on a trending NFT entry.
class TrendingNftDataDto {
  const TrendingNftDataDto({
    required this.floorPrice,
    required this.floorPriceInUsd24hPercentageChange,
    required this.h24Volume,
    required this.h24AverageSalePrice,
    required this.sparkline,
    required this.content,
  });

  final String floorPrice;
  final String floorPriceInUsd24hPercentageChange;
  final String h24Volume;
  final String h24AverageSalePrice;
  final String sparkline;
  final TrendingContentDto? content;

  factory TrendingNftDataDto.fromJson(Map<String, dynamic> json) {
    final rawContent = json['content'];
    return TrendingNftDataDto(
      floorPrice: json['floor_price'] as String? ?? '',
      floorPriceInUsd24hPercentageChange:
          json['floor_price_in_usd_24h_percentage_change'] as String? ?? '',
      h24Volume: json['h24_volume'] as String? ?? '',
      h24AverageSalePrice: json['h24_average_sale_price'] as String? ?? '',
      sparkline: json['sparkline'] as String? ?? '',
      content: rawContent is Map<String, dynamic>
          ? TrendingContentDto.fromJson(rawContent)
          : null,
    );
  }
}

/// An element of the `categories` array.
class TrendingCategoryDto {
  const TrendingCategoryDto({
    required this.id,
    required this.name,
    required this.top3CoinsImages,
    required this.marketCap1hChange,
    required this.slug,
    required this.coinsCount,
    required this.data,
  });

  final int id;
  final String name;
  final List<String> top3CoinsImages;
  final double marketCap1hChange;
  final String slug;
  final String coinsCount;
  final TrendingCategoryDataDto? data;

  factory TrendingCategoryDto.fromJson(Map<String, dynamic> json) {
    final rawImages = json['top_3_coins_images'];
    final rawData = json['data'];
    return TrendingCategoryDto(
      id: _i(json['id']),
      name: json['name'] as String? ?? '',
      top3CoinsImages: rawImages is List
          ? rawImages.whereType<String>().toList(growable: false)
          : const [],
      marketCap1hChange: _d(json['market_cap_1h_change']),
      slug: json['slug'] as String? ?? '',
      coinsCount: json['coins_count']?.toString() ?? '',
      data: rawData is Map<String, dynamic>
          ? TrendingCategoryDataDto.fromJson(rawData)
          : null,
    );
  }

  static double _d(Object? v) => (v as num?)?.toDouble() ?? 0;
  static int _i(Object? v) => (v as num?)?.toInt() ?? 0;
}

/// Nested `data` on a trending category entry.
class TrendingCategoryDataDto {
  const TrendingCategoryDataDto({
    required this.marketCap,
    required this.marketCapBtc,
    required this.totalVolume,
    required this.totalVolumeBtc,
    required this.marketCapChangePercentage24h,
    required this.sparkline,
  });

  final double marketCap;
  final double marketCapBtc;
  final double totalVolume;
  final double totalVolumeBtc;
  final Map<String, double> marketCapChangePercentage24h;
  final String sparkline;

  factory TrendingCategoryDataDto.fromJson(Map<String, dynamic> json) {
    return TrendingCategoryDataDto(
      marketCap: _d(json['market_cap']),
      marketCapBtc: _d(json['market_cap_btc']),
      totalVolume: _d(json['total_volume']),
      totalVolumeBtc: _d(json['total_volume_btc']),
      marketCapChangePercentage24h: _currencyMap(
        json['market_cap_change_percentage_24h'],
      ),
      sparkline: json['sparkline'] as String? ?? '',
    );
  }

  static double _d(Object? v) => (v as num?)?.toDouble() ?? 0;

  static Map<String, double> _currencyMap(Object? node) {
    if (node is! Map) return const {};

    return Map<String, double>.unmodifiable(
      node.map((key, value) => MapEntry(key.toString(), _d(value))),
    );
  }
}
