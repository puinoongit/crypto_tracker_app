import 'package:intl/intl.dart';

/// Locale-agnostic display formatting for currency, large numbers, and
/// percentages. Pure functions → trivially unit-testable.
abstract final class Formatters {
  /// Formats a USD price. Small prices keep more precision so sub-cent coins
  /// don't render as `$0.00`.
  static String price(num? value) {
    if (value == null) return '—';
    final decimals = value >= 1 ? 2 : 6;
    return NumberFormat.currency(
      symbol: r'$',
      decimalDigits: decimals,
    ).format(value);
  }

  /// Compacts large values, e.g. `$1.2B`, `$345.0M`.
  static String compactCurrency(num? value) {
    if (value == null) return '—';
    return NumberFormat.compactCurrency(
      symbol: r'$',
      decimalDigits: 1,
    ).format(value);
  }

  /// Compacts a plain count, e.g. `19.7M`.
  static String compact(num? value) {
    if (value == null) return '—';
    return NumberFormat.compact().format(value);
  }

  /// Signed percentage with two decimals, e.g. `+2.31%` / `-0.84%`.
  static String percentage(num? value) {
    if (value == null) return '—';
    final sign = value > 0 ? '+' : '';
    return '$sign${value.toStringAsFixed(2)}%';
  }
}
