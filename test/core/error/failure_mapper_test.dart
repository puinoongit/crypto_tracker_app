import 'package:crypto_tracker_app/core/error/exceptions.dart';
import 'package:crypto_tracker_app/core/error/failure.dart';
import 'package:crypto_tracker_app/core/error/failure_mapper.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('mapExceptionToFailure', () {
    test('maps each data-layer exception to its domain failure', () {
      expect(
        mapExceptionToFailure(const NoInternetException()),
        isA<NoInternetFailure>(),
      );
      expect(
        mapExceptionToFailure(const TimeoutException()),
        isA<TimeoutFailure>(),
      );
      expect(
        mapExceptionToFailure(const CacheException()),
        isA<CacheFailure>(),
      );
      expect(
        mapExceptionToFailure(const ServerException(statusCode: 503)),
        isA<ServerFailure>().having((f) => f.statusCode, 'statusCode', 503),
      );
    });

    test('falls back to UnknownFailure for unrecognized errors', () {
      expect(mapExceptionToFailure(Exception('boom')), isA<UnknownFailure>());
      expect(mapExceptionToFailure('a string'), isA<UnknownFailure>());
    });
  });
}
