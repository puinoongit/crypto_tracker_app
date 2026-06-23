import 'package:crypto_tracker_app/features/coin_detail/data/dto/coin_detail_dto.dart';
import 'package:flutter_test/flutter_test.dart';

/// Verifies [CoinDetailDto.fromApi] handles a real CoinGecko payload shape
/// (eutbl — tokenized treasury fund with null max_supply and zero volume).
void main() {
  test('parses eutbl-like nested API payload', () {
    final entity = CoinDetailDto.fromApi({
      'id': 'eutbl',
      'symbol': 'eutbl',
      'name': 'Spiko EU T-Bills Money Market Fund',
      'market_cap_rank': 71,
      'image': {
        'large':
            'https://coin-images.coingecko.com/coins/images/39657/large/EUTBL.png',
      },
      'description': {
        'en':
            'Spiko EU T-Bills Money Market Fund is a fully-licensed EUR money market fund.',
      },
      'market_data': {
        'current_price': {'usd': 1.2},
        'market_cap': {'usd': 934211404},
        'total_volume': {'usd': 0.0},
        'ath': {'usd': 1.26},
        'ath_change_percentage': {'usd': -4.46556},
        'atl': {'usd': 1.011},
        'atl_change_percentage': {'usd': 19.16725},
        'price_change_percentage_24h': -0.30013,
        'circulating_supply': 775468473.08614,
        'max_supply': null,
      },
    }).toEntity();

    expect(entity.id, 'eutbl');
    expect(entity.currentPrice, 1.2);
    expect(entity.marketCapRank, 71);
    expect(entity.totalVolume, 0);
    expect(entity.maxSupply, isNull);
    expect(entity.ath, 1.26);
    expect(entity.description, contains('fully-licensed'));
  });
}
