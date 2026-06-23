import 'package:crypto_tracker_app/features/home/data/dto/coin_market_dto.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/fixtures.dart';

void main() {
  group('CoinMarketDto', () {
    test('parses a well-formed JSON element and maps to an entity', () {
      final dto = CoinMarketDto.fromJson(marketJson(rank: 3));
      final entity = dto.toEntity();

      expect(entity.id, 'bitcoin');
      expect(entity.symbol, 'btc');
      expect(entity.currentPrice, 50000);
      expect(entity.marketCapRank, 3);
      expect(entity.isPriceUp, isTrue);
    });

    test('parses sparkline prices from the API payload', () {
      final dto = CoinMarketDto.fromJson(
        marketJson(sparklinePrices: const [1, 2, 3, 4]),
      );

      expect(dto.sparklinePrices, [1.0, 2.0, 3.0, 4.0]);
      expect(dto.toEntity().sparklinePrices, [1.0, 2.0, 3.0, 4.0]);
    });

    test('coerces missing/null fields to safe defaults', () {
      final dto = CoinMarketDto.fromJson(const {});

      expect(dto.id, '');
      expect(dto.currentPrice, 0);
      expect(dto.marketCapRank, 0);
      expect(dto.sparklinePrices, isEmpty);
    });

    test('coerces integer JSON numbers to double', () {
      final dto = CoinMarketDto.fromJson(const {'current_price': 7});
      expect(dto.currentPrice, 7.0);
      expect(dto.currentPrice, isA<double>());
    });

    test('toJson round-trips back to an equivalent DTO', () {
      final original = CoinMarketDto.fromJson(marketJson());
      final restored = CoinMarketDto.fromJson(original.toJson());

      expect(restored.toEntity(), original.toEntity());
    });
  });
}
