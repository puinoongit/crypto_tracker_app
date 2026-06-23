/// Small, pure text helpers.
abstract final class TextUtils {
  static final _tagPattern = RegExp(r'<[^>]*>');
  static final _whitespacePattern = RegExp(r'\s+');

  /// Strips HTML tags and collapses whitespace. CoinGecko coin descriptions are
  /// HTML; we render plain text, so we sanitize them for display.
  static String stripHtml(String input) {
    return input
        .replaceAll(_tagPattern, '')
        .replaceAll('&nbsp;', ' ')
        .replaceAll(_whitespacePattern, ' ')
        .trim();
  }
}
