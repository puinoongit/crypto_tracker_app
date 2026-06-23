import 'package:crypto_tracker_app/core/utils/text_utils.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('TextUtils.stripHtml', () {
    test('removes tags and collapses whitespace', () {
      expect(
        TextUtils.stripHtml('<p>The first <b>cryptocurrency</b>.</p>'),
        'The first cryptocurrency.',
      );
    });

    test('decodes &nbsp; and trims', () {
      expect(TextUtils.stripHtml('  Hello&nbsp;world  '), 'Hello world');
    });

    test('returns empty string for tag-only input', () {
      expect(TextUtils.stripHtml('<br/><br/>'), '');
    });
  });
}
