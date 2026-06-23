/// Parses `GET /search?query=` from CoinGecko.
///
/// Only the `coins` array is used; we extract ids and then hydrate full market
/// data via `/coins/markets?ids=…` so list rows still have price + sparkline.
class SearchApiResponseDto {
  const SearchApiResponseDto({required this.coinIds});

  final List<String> coinIds;

  factory SearchApiResponseDto.fromJson(Map<String, dynamic> json) {
    final coins = json['coins'];
    if (coins is! List) return const SearchApiResponseDto(coinIds: []);

    final ids = <String>[];
    for (final entry in coins) {
      if (entry is! Map) continue;
      final id = entry['id'];
      if (id is String && id.isNotEmpty) {
        ids.add(id);
      }
      if (ids.length >= SearchApiResponseDto.maxResults) break;
    }
    return SearchApiResponseDto(coinIds: ids);
  }

  /// CoinGecko search can return many hits; cap to keep the markets call small.
  static const int maxResults = 20;
}
