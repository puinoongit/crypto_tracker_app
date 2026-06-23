import 'package:crypto_tracker_app/features/home/data/dto/global_market_dto.dart';
import 'package:crypto_tracker_app/features/home/data/dto/trending_coin_dto.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('GlobalMarketDto', () {
    test('parses nested /global payload', () {
      final entity = GlobalMarketDto.fromApi(const {
        'data': {
          'total_market_cap': {'usd': 2440000000000},
          'total_volume': {'usd': 93220000000},
          'market_cap_change_percentage_24h_usd': -0.42,
        },
      }).toEntity();

      expect(entity.totalMarketCap, 2440000000000);
      expect(entity.totalVolume, 93220000000);
      expect(entity.marketCapChangePercentage24h, -0.42);
      expect(entity.isMarketUp, isFalse);
    });

    test('round-trips through the flat cache format', () {
      final api = GlobalMarketDto.fromApi(const {
        'data': {
          'total_market_cap': {'usd': 100},
          'total_volume': {'usd': 50},
          'market_cap_change_percentage_24h_usd': 1.5,
        },
      });
      final restored = GlobalMarketDto.fromJson(api.toJson());
      expect(restored.toEntity(), api.toEntity());
    });

    test('tolerates a missing data block', () {
      final entity = GlobalMarketDto.fromApi(const {}).toEntity();
      expect(entity.totalMarketCap, 0);
    });
  });

  group('TrendingCoinDto', () {
    test('parses an unwrapped /search/trending item', () {
      final entity = TrendingCoinDto.fromApiItem(const {
        'id': 'bonk',
        'name': 'Bonk',
        'symbol': 'bonk',
        'small': 'https://example.com/bonk.png',
        'market_cap_rank': 102,
        'data': {
          'price_change_percentage_24h': {'usd': -1.36},
          'sparkline': 'https://www.coingecko.com/coins/10239/sparkline.svg',
        },
      }).toEntity();

      expect(entity.id, 'bonk');
      expect(entity.marketCapRank, 102);
      expect(entity.thumb, 'https://example.com/bonk.png');
      expect(entity.priceChangePercentage24h, -1.36);
      expect(entity.sparklineUrl, contains('sparkline.svg'));
      expect(entity.isPriceUp, isFalse);
    });

    test('round-trips through the flat cache format', () {
      final api = TrendingCoinDto.fromApiItem(const {
        'id': 'near',
        'name': 'NEAR',
        'symbol': 'near',
        'thumb': 'x',
        'market_cap_rank': 33,
        'data': {
          'price_change_percentage_24h': {'usd': 15.31},
        },
      });
      final restored = TrendingCoinDto.fromJson(api.toJson());
      expect(restored.toEntity(), api.toEntity());
    });
  });
}
