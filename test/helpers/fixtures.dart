import 'package:crypto_tracker_app/features/coin_detail/domain/entity/coin_detail.dart';
import 'package:crypto_tracker_app/features/home/domain/entity/coin.dart';
import 'package:crypto_tracker_app/features/home/domain/entity/global_market.dart';
import 'package:crypto_tracker_app/features/home/domain/entity/trending_coin.dart';

/// Deterministic test fixtures shared across the suite.

Coin buildCoin({
  String id = 'bitcoin',
  String symbol = 'btc',
  String name = 'Bitcoin',
  double price = 50000,
  double change = 2.5,
  int rank = 1,
  List<double> sparklinePrices = const [48000, 49000, 48500, 50000, 51000],
}) {
  return Coin(
    id: id,
    symbol: symbol,
    name: name,
    imageUrl: 'https://example.com/$id.png',
    currentPrice: price,
    priceChangePercentage24h: change,
    marketCap: 1000000000,
    marketCapRank: rank,
    totalVolume: 50000000,
    sparklinePrices: sparklinePrices,
  );
}

/// Builds [count] coins with distinct ids/names/ranks.
List<Coin> buildCoins(int count, {int startRank = 1}) {
  return List.generate(
    count,
    (i) => buildCoin(
      id: 'coin_${startRank + i}',
      symbol: 'c${startRank + i}',
      name: 'Coin ${startRank + i}',
      rank: startRank + i,
    ),
  );
}

CoinDetail buildCoinDetail({
  String id = 'bitcoin',
  String name = 'Bitcoin',
  double price = 50000,
}) {
  return CoinDetail(
    id: id,
    symbol: 'btc',
    name: name,
    imageUrl: 'https://example.com/$id.png',
    currentPrice: price,
    priceChangePercentage24h: 2.5,
    marketCap: 1000000000,
    marketCapRank: 1,
    totalVolume: 50000000,
    ath: 69000,
    athChangePercentage: -27.5,
    atl: 67.81,
    atlChangePercentage: 73000,
    circulatingSupply: 19000000,
    maxSupply: 21000000,
    description: '<p>The first cryptocurrency.</p>',
  );
}

GlobalMarket buildGlobalMarket({double change = -0.42}) => GlobalMarket(
  totalMarketCap: 2440000000000,
  marketCapChangePercentage24h: change,
  totalVolume: 93220000000,
);

List<TrendingCoin> buildTrendingCoins({
  int count = 3,
  bool withSparkline = false,
}) => List.generate(
  count,
  (i) => TrendingCoin(
    id: 'trend_$i',
    name: 'Trend $i',
    symbol: 't$i',
    thumb: 'https://example.com/t$i.png',
    marketCapRank: 100 + i,
    priceChangePercentage24h: i.isEven ? 5.0 : -3.0,
    sparklineUrl: withSparkline
        ? 'https://www.coingecko.com/coins/$i/sparkline.svg'
        : '',
  ),
);

/// A `/coins/markets` JSON element.
Map<String, dynamic> marketJson({
  String id = 'bitcoin',
  int rank = 1,
  List<double> sparklinePrices = const [48000, 49000, 48500, 50000, 51000],
}) => {
  'id': id,
  'symbol': 'btc',
  'name': 'Bitcoin',
  'image': 'https://example.com/$id.png',
  'current_price': 50000,
  'price_change_percentage_24h': 2.5,
  'market_cap': 1000000000,
  'market_cap_rank': rank,
  'total_volume': 50000000,
  'sparkline_in_7d': {'price': sparklinePrices},
};

/// A `/coins/{id}` JSON payload (nested API shape).
Map<String, dynamic> coinDetailApiJson({String id = 'bitcoin'}) => {
  'id': id,
  'symbol': 'btc',
  'name': 'Bitcoin',
  'image': {'large': 'https://example.com/$id.png'},
  'market_cap_rank': 1,
  'description': {'en': '<p>The first cryptocurrency.</p>'},
  'market_data': {
    'current_price': {'usd': 50000},
    'market_cap': {'usd': 1000000000},
    'total_volume': {'usd': 50000000},
    'ath': {'usd': 69000},
    'ath_change_percentage': {'usd': -27.5},
    'atl': {'usd': 67.81},
    'atl_change_percentage': {'usd': 73000},
    'price_change_percentage_24h': 2.5,
    'circulating_supply': 19000000,
    'max_supply': 21000000,
  },
};
