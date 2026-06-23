import 'package:crypto_tracker_app/features/search/data/dto/search_api_response_dto.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('SearchApiResponseDto', () {
    test('extracts coin ids and caps at maxResults', () {
      final coins = List.generate(
        25,
        (i) => {'id': 'coin-$i', 'name': 'Coin $i', 'symbol': 'C$i'},
      );

      final dto = SearchApiResponseDto.fromJson({'coins': coins});

      expect(dto.coinIds, hasLength(SearchApiResponseDto.maxResults));
      expect(dto.coinIds.first, 'coin-0');
      expect(dto.coinIds.last, 'coin-19');
    });

    test('returns empty list when coins key is missing', () {
      final dto = SearchApiResponseDto.fromJson(const {});
      expect(dto.coinIds, isEmpty);
    });

    test('skips invalid entries', () {
      final dto = SearchApiResponseDto.fromJson({
        'coins': [
          {'id': ''},
          {'id': 'valid'},
          42,
        ],
      });

      expect(dto.coinIds, ['valid']);
    });
  });
}
