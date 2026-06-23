import 'package:crypto_tracker_app/features/home/data/dto/coin_market_dto.dart';
import 'package:crypto_tracker_app/features/home/data/dto/coin_market_item_dto.dart';
import 'package:flutter_test/flutter_test.dart';

/// Minimal Bitcoin-shaped `/coins/markets` element (sparkline trimmed).
Map<String, dynamic> bitcoinMarketApiJson() => {
  'id': 'bitcoin',
  'symbol': 'btc',
  'name': 'Bitcoin',
  'image':
      'https://coin-images.coingecko.com/coins/images/1/large/bitcoin.png?1696501400',
  'current_price': 65469,
  'market_cap': 1312313689203,
  'market_cap_rank': 1,
  'fully_diluted_valuation': 1312313689203,
  'total_volume': 24255517016,
  'high_24h': 65442,
  'low_24h': 63232,
  'price_change_24h': 1427.83,
  'price_change_percentage_24h': 2.22956,
  'market_cap_change_24h': 28649381109,
  'market_cap_change_percentage_24h': 2.23184,
  'circulating_supply': 20046371.0,
  'total_supply': 20046371.0,
  'max_supply': 21000000.0,
  'ath': 126080,
  'ath_change_percentage': -48.0737,
  'ath_date': '2025-10-06T18:57:42.558Z',
  'atl': 67.81,
  'atl_change_percentage': 96448.57993,
  'atl_date': '2013-07-06T00:00:00.000Z',
  'roi': null,
  'last_updated': '2026-06-22T13:59:55.819Z',
  'sparkline_in_7d': {
    'price': [66529.06, 66428.78, 65469.46],
  },
  'price_change_percentage_24h_in_currency': 2.2295599835434365,
};

Map<String, dynamic> ethereumMarketApiJson() => {
  'id': 'ethereum',
  'symbol': 'eth',
  'name': 'Ethereum',
  'image':
      'https://coin-images.coingecko.com/coins/images/279/large/ethereum.png?1696501628',
  'current_price': 1773.96,
  'market_cap': 214057880593,
  'market_cap_rank': 2,
  'fully_diluted_valuation': 214057880593,
  'total_volume': 13096843296,
  'high_24h': 1772.87,
  'low_24h': 1704.15,
  'price_change_24h': 51.37,
  'price_change_percentage_24h': 2.98235,
  'market_cap_change_24h': 6204292780,
  'market_cap_change_percentage_24h': 2.98493,
  'circulating_supply': 120683877.0940639,
  'total_supply': 120683877.0940639,
  'max_supply': null,
  'ath': 4946.05,
  'ath_change_percentage': -64.13372,
  'ath_date': '2025-08-24T19:21:03.333Z',
  'atl': 0.432979,
  'atl_change_percentage': 409611.38164,
  'atl_date': '2015-10-20T00:00:00.000Z',
  'roi': {
    'times': 35.225790364475785,
    'currency': 'btc',
    'percentage': 3522.579036447579,
  },
  'last_updated': '2026-06-22T13:59:55.848Z',
  'sparkline_in_7d': {
    'price': [1775.25, 1813.90, 1773.96],
  },
  'price_change_percentage_24h_in_currency': 2.982351948592512,
};

void main() {
  group('CoinMarketsApiResponse', () {
    test('parses a top-level JSON array', () {
      final response = CoinMarketsApiResponse.fromJsonList([
        bitcoinMarketApiJson(),
        ethereumMarketApiJson(),
      ]);

      expect(response.items, hasLength(2));

      final btc = response.items.first;
      expect(btc.id, 'bitcoin');
      expect(btc.symbol, 'btc');
      expect(btc.currentPrice, 65469);
      expect(btc.marketCapRank, 1);
      expect(btc.maxSupply, 21000000);
      expect(btc.ath, 126080);
      expect(btc.sparklineIn7d.prices, [66529.06, 66428.78, 65469.46]);
      expect(btc.roi, isNull);

      final eth = response.items[1];
      expect(eth.maxSupply, isNull);
      expect(eth.roi?.currency, 'btc');
      expect(eth.roi?.times, closeTo(35.226, 0.001));
    });

    test('maps items to CoinMarketDto for the list UI', () {
      final dtos = CoinMarketsApiResponse.fromJsonList([
        bitcoinMarketApiJson(),
      ]).items.map(CoinMarketDto.fromApiItem).toList();

      expect(dtos.first.symbol, 'btc');
      expect(dtos.first.sparklinePrices, hasLength(3));
      expect(dtos.first.toEntity().isPriceUp, isTrue);
    });

    test('tolerates an empty array', () {
      expect(CoinMarketsApiResponse.fromJsonList(const []).items, isEmpty);
    });
  });
}
