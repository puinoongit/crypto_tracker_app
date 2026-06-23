import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/fixtures.dart';

void main() {
  group('Coin', () {
    test('isPriceUp reflects the 24h change sign', () {
      expect(buildCoin(change: 1.2).isPriceUp, isTrue);
      expect(buildCoin(change: 0).isPriceUp, isTrue);
      expect(buildCoin(change: -3.4).isPriceUp, isFalse);
    });

    test('value equality is by content (Equatable)', () {
      expect(buildCoin(), buildCoin());
      expect(buildCoin(id: 'a'), isNot(buildCoin(id: 'b')));
    });
  });

  group('CoinDetail', () {
    test('isPriceUp reflects the 24h change sign', () {
      expect(buildCoinDetail().isPriceUp, isTrue);
    });

    test('value equality is by content', () {
      expect(buildCoinDetail(), buildCoinDetail());
      expect(buildCoinDetail(name: 'A'), isNot(buildCoinDetail(name: 'B')));
    });
  });
}
