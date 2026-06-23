import 'package:crypto_tracker_app/features/home/data/dto/trending_api_response_dto.dart';
import 'package:crypto_tracker_app/features/home/data/dto/trending_coin_dto.dart';
import 'package:flutter_test/flutter_test.dart';

/// Minimal `/search/trending` fixture based on a live API response.
Map<String, dynamic> trendingApiJson() => {
  'coins': [
    {
      'item': {
        'id': 'arcium',
        'coin_id': 54948,
        'name': 'Arcium',
        'symbol': 'ARX',
        'market_cap_rank': 362,
        'thumb':
            'https://coin-images.coingecko.com/coins/images/54948/standard/arcium-logo.jpg',
        'small':
            'https://coin-images.coingecko.com/coins/images/54948/small/arcium-logo.jpg',
        'large':
            'https://coin-images.coingecko.com/coins/images/54948/large/arcium-logo.jpg',
        'slug': 'arcium',
        'price_btc': 5.178320611022034e-06,
        'score': 0,
        'data': {
          'price': 0.3251261000278755,
          'price_btc': '0.000004968496775445493',
          'price_change_percentage_24h': {
            'usd': -8.388509682004774,
            'thb': -8.388509682004788,
            'btc': -10.219529965175218,
          },
          'market_cap': r'$67,941,081',
          'market_cap_btc': '1038.132616029704',
          'total_volume': r'$78,799,852',
          'total_volume_btc': '1204.199885487594',
          'sparkline': 'https://www.coingecko.com/coins/54948/sparkline.svg',
          'content': null,
        },
      },
    },
    {
      'item': {
        'id': 'bitcoin',
        'coin_id': 1,
        'name': 'Bitcoin',
        'symbol': 'BTC',
        'market_cap_rank': 1,
        'thumb':
            'https://coin-images.coingecko.com/coins/images/1/standard/bitcoin.png',
        'small':
            'https://coin-images.coingecko.com/coins/images/1/small/bitcoin.png',
        'large':
            'https://coin-images.coingecko.com/coins/images/1/large/bitcoin.png',
        'slug': 'bitcoin',
        'price_btc': 1.0,
        'score': 5,
        'data': {
          'price': 65377.38,
          'price_btc': '1.0',
          'price_change_percentage_24h': {'usd': 2.165496120836659},
          'market_cap': r'$1,310,479,363,099',
          'market_cap_btc': '20046371.0',
          'total_volume': r'$23,700,789,586',
          'total_volume_btc': '362491.169065726',
          'sparkline': 'https://www.coingecko.com/coins/1/sparkline.svg',
          'content': {
            'title': 'About Bitcoin (BTC)',
            'description':
                'Bitcoin is the world\'s first decentralized cryptocurrency.',
          },
        },
      },
    },
  ],
  'nfts': [
    {
      'id': 'pudgy-penguins',
      'name': 'Pudgy Penguins',
      'symbol': 'PPG',
      'thumb':
          'https://coin-images.coingecko.com/nft_contracts/images/38/standard/pudgy.jpg',
      'nft_contract_id': 38,
      'native_currency_symbol': 'eth',
      'floor_price_in_native_currency': 4.7989829998,
      'floor_price_24h_percentage_change': 8.23660125734908,
      'data': {
        'floor_price': '4.80 ETH',
        'floor_price_in_usd_24h_percentage_change': '8.23660125734908',
        'h24_volume': '119.86 ETH',
        'h24_average_sale_price': '4.61 ETH',
        'sparkline': 'https://www.coingecko.com/nft/38/sparkline.svg',
        'content': null,
      },
    },
  ],
  'categories': [
    {
      'id': 82,
      'name': 'Derivatives',
      'top_3_coins_images': [
        'https://assets.coingecko.com/coins/images/17500/small/hjnIm9bV.jpg',
      ],
      'market_cap_1h_change': 1.1041770326329914,
      'slug': 'decentralized-derivatives',
      'coins_count': '124',
      'data': {
        'market_cap': 17396451916.097416,
        'market_cap_btc': 266089.41800925095,
        'total_volume': 734715798.2168955,
        'total_volume_btc': 11237.92944059095,
        'market_cap_change_percentage_24h': {'usd': -1.2740547015294197},
        'sparkline': 'https://www.coingecko.com/categories/82/sparkline.svg',
      },
    },
  ],
};

void main() {
  group('TrendingApiResponseDto', () {
    test('parses coins, nfts, and categories', () {
      final response = TrendingApiResponseDto.fromJson(trendingApiJson());

      expect(response.coins, hasLength(2));
      expect(response.nfts, hasLength(1));
      expect(response.categories, hasLength(1));

      final arcium = response.coins.first.item;
      expect(arcium.id, 'arcium');
      expect(arcium.coinId, 54948);
      expect(arcium.symbol, 'ARX');
      expect(arcium.marketCapRank, 362);
      expect(arcium.data?.price, closeTo(0.3251, 0.0001));
      expect(arcium.data?.priceBtc, '0.000004968496775445493');
      expect(arcium.priceChangePercentage24hUsd, closeTo(-8.389, 0.001));
      expect(arcium.data?.priceChangePercentage24h, hasLength(3));
      expect(arcium.data?.marketCap, r'$67,941,081');
      expect(arcium.data?.sparkline, contains('sparkline.svg'));

      final bitcoin = response.coins[1].item;
      expect(bitcoin.data?.content?.title, 'About Bitcoin (BTC)');

      final nft = response.nfts.first;
      expect(nft.id, 'pudgy-penguins');
      expect(nft.nativeCurrencySymbol, 'eth');
      expect(nft.floorPriceInNativeCurrency, closeTo(4.799, 0.001));
      expect(nft.data?.floorPrice, '4.80 ETH');

      final category = response.categories.first;
      expect(category.name, 'Derivatives');
      expect(category.slug, 'decentralized-derivatives');
      expect(category.top3CoinsImages, hasLength(1));
      expect(category.data?.marketCap, closeTo(17396451916, 1));
      expect(
        category.data?.marketCapChangePercentage24h['usd'],
        closeTo(-1.274, 0.001),
      );
    });

    test('maps coin items to TrendingCoinDto for the carousel', () {
      final dtos = TrendingApiResponseDto.fromJson(
        trendingApiJson(),
      ).coins.map((e) => TrendingCoinDto.fromItem(e.item)).toList();

      expect(dtos.first.symbol, 'ARX');
      expect(dtos.first.thumb, contains('/small/'));
      expect(dtos.first.priceChangePercentage24h, closeTo(-8.389, 0.001));
      expect(dtos.first.sparklineUrl, contains('sparkline.svg'));
      expect(dtos.last.toEntity().isPriceUp, isTrue);
    });

    test('tolerates missing arrays', () {
      final response = TrendingApiResponseDto.fromJson(const {});

      expect(response.coins, isEmpty);
      expect(response.nfts, isEmpty);
      expect(response.categories, isEmpty);
    });
  });
}
