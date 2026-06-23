import 'package:crypto_tracker_app/features/coin_detail/data/dto/coin_detail_dto.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/fixtures.dart';

void main() {
  group('CoinDetailDto.fromApi', () {
    test('flattens the nested API payload into a domain entity', () {
      final entity = CoinDetailDto.fromApi(coinDetailApiJson()).toEntity();

      expect(entity.id, 'bitcoin');
      expect(entity.imageUrl, 'https://example.com/bitcoin.png');
      expect(entity.currentPrice, 50000);
      expect(entity.ath, 69000);
      expect(entity.atl, 67.81);
      expect(entity.circulatingSupply, 19000000);
      expect(entity.maxSupply, 21000000);
      expect(entity.description, contains('cryptocurrency'));
    });

    test('tolerates a missing market_data block', () {
      final entity = CoinDetailDto.fromApi(const {
        'id': 'x',
        'symbol': 's',
        'name': 'X',
      }).toEntity();

      expect(entity.currentPrice, 0);
      expect(entity.marketCap, 0);
      expect(entity.description, '');
    });

    test('ignores unused API fields with unexpected shapes', () {
      final entity = CoinDetailDto.fromApi({
        'id': 'tether-gold',
        'symbol': 'xaut',
        'name': 'Tether Gold',
        'market_cap_rank': 39,
        'links': {'subreddit_url': null},
        'hashing_algorithm': null,
        'image': {
          'large':
              'https://coin-images.coingecko.com/coins/images/10481/large/logo.png',
        },
        'description': {'en': 'Tokenized gold.'},
        'market_data': {
          'current_price': {'usd': 4097.32},
          'total_value_locked': {'btc': 47002, 'usd': 2930235732},
          'market_cap': {'usd': 2510000000},
          'total_volume': {'usd': 120000000},
          'ath': {'usd': 5504.62},
          'ath_change_percentage': {'usd': -25.67},
          'atl': {'usd': 1447.84},
          'atl_change_percentage': {'usd': 183.0},
          'price_change_percentage_24h': -2.1,
          'circulating_supply': 612823.66,
          'max_supply': null,
        },
      }).toEntity();

      expect(entity.id, 'tether-gold');
      expect(entity.currentPrice, 4097.32);
    });
  });

  group('CoinDetailDto cache format', () {
    test('toJson/fromJson round-trips losslessly', () {
      final api = CoinDetailDto.fromApi(coinDetailApiJson());
      final restored = CoinDetailDto.fromJson(api.toJson());

      expect(restored.toEntity(), api.toEntity());
    });
  });
}
