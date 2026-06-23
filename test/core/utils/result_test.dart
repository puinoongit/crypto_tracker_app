import 'package:crypto_tracker_app/core/error/failure.dart';
import 'package:crypto_tracker_app/core/utils/result.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Result', () {
    test('Ok exposes value and folds to the success branch', () {
      const result = Result<int>.ok(42);

      expect(result.isOk, isTrue);
      expect(result.isErr, isFalse);
      expect(result.valueOrNull, 42);
      expect(result.fold((_) => 'err', (v) => 'ok:$v'), 'ok:42');
    });

    test('Err carries the failure and folds to the error branch', () {
      const result = Result<int>.err(NoInternetFailure());

      expect(result.isErr, isTrue);
      expect(result.valueOrNull, isNull);
      expect(
        result.fold((f) => f.runtimeType.toString(), (_) => 'ok'),
        'NoInternetFailure',
      );
    });
  });
}
