import 'package:crypto_tracker_app/features/home/data/dto/global_api_response_dto.dart';
import 'package:crypto_tracker_app/features/home/data/dto/global_market_dto.dart';
import 'package:flutter_test/flutter_test.dart';

/// Fixture shaped like a live `GET /global` response (trimmed currency lists).
Map<String, dynamic> globalApiJson() => {
  'data': {
    'active_cryptocurrencies': 17408,
    'upcoming_icos': 0,
    'ongoing_icos': 49,
    'ended_icos': 3376,
    'markets': 1488,
    'total_market_cap': {
      'usd': 2322483287838.069,
      'btc': 35522490.74393947,
      'thb': 76486342118371.12,
    },
    'total_volume': {
      'usd': 66107663813.26645,
      'btc': 1011119.8165374921,
      'thb': 2177123692362.304,
    },
    'market_cap_percentage': {
      'btc': 56.43289808843186,
      'eth': 9.210931425165048,
      'xrp': 3.0917595717154156,
    },
    'market_cap_change_percentage_24h_usd': 1.7620834944215427,
    'volume_change_percentage_24h_usd': 30.0877801077707,
    'updated_at': 1782136151,
  },
};

void main() {
  group('GlobalApiResponseDto', () {
    test('parses the full /global envelope', () {
      final response = GlobalApiResponseDto.fromJson(globalApiJson());
      final data = response.data;

      expect(data.activeCryptocurrencies, 17408);
      expect(data.ongoingIcos, 49);
      expect(data.markets, 1488);
      expect(data.currency(data.totalMarketCap), 2322483287838.069);
      expect(data.currency(data.totalVolume), 66107663813.26645);
      expect(data.currency(data.totalMarketCap, 'thb'), 76486342118371.12);
      expect(data.marketCapPercentage['btc'], closeTo(56.43, 0.01));
      expect(data.marketCapChangePercentage24hUsd, closeTo(1.762, 0.001));
      expect(data.volumeChangePercentage24hUsd, closeTo(30.088, 0.001));
      expect(data.updatedAt, 1782136151);
    });

    test('maps to GlobalMarketDto for the header card', () {
      final market = GlobalMarketDto.fromApi(globalApiJson()).toEntity();

      expect(market.totalMarketCap, 2322483287838.069);
      expect(market.totalVolume, 66107663813.26645);
      expect(market.marketCapChangePercentage24h, closeTo(1.762, 0.001));
      expect(market.isMarketUp, isTrue);
    });

    test('tolerates a missing data block', () {
      final data = GlobalApiResponseDto.fromJson(const {}).data;

      expect(data.activeCryptocurrencies, 0);
      expect(data.totalMarketCap, isEmpty);
      expect(GlobalMarketDto.fromApi(const {}).totalMarketCap, 0);
    });
  });
}
