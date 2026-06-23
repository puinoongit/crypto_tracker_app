import 'exceptions.dart';
import 'failure.dart';

/// Maps internal data-layer [Exception]s to domain [Failure]s.
///
/// Repositories call this in their `catch` blocks so that no raw exception ever
/// escapes the data layer. Any unrecognized error degrades safely to
/// [UnknownFailure].
Failure mapExceptionToFailure(Object error) {
  return switch (error) {
    NoInternetException() => const NoInternetFailure(),
    TimeoutException() => const TimeoutFailure(),
    ServerException(:final statusCode) => ServerFailure(statusCode: statusCode),
    CacheException() => const CacheFailure(),
    _ => const UnknownFailure(),
  };
}
