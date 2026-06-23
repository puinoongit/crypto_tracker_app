import 'package:crypto_tracker_app/core/utils/formatters.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Formatters', () {
    test('price uses 2 decimals for >= 1 and more precision below 1', () {
      expect(Formatters.price(50000), r'$50,000.00');
      expect(Formatters.price(0.123456), r'$0.123456');
      expect(Formatters.price(null), '—');
    });

    test('percentage is signed with two decimals', () {
      expect(Formatters.percentage(2.31), '+2.31%');
      expect(Formatters.percentage(-0.84), '-0.84%');
      expect(Formatters.percentage(0), '0.00%');
      expect(Formatters.percentage(null), '—');
    });

    test('compactCurrency abbreviates large values', () {
      expect(Formatters.compactCurrency(1200000000), contains('B'));
      expect(Formatters.compactCurrency(null), '—');
    });
  });
}
