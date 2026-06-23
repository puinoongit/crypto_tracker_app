import 'package:equatable/equatable.dart';

/// Domain-level representation of something that went wrong.
///
/// Failures are the *only* error type allowed to reach the presentation layer.
/// They carry a stable [kind] that the UI maps to a localized, user-friendly
/// message — never a raw exception or stack trace.
sealed class Failure extends Equatable {
  const Failure();

  @override
  List<Object?> get props => const [];
}

/// The device has no internet connectivity.
class NoInternetFailure extends Failure {
  const NoInternetFailure();
}

/// A request exceeded the configured connect/receive timeout.
class TimeoutFailure extends Failure {
  const TimeoutFailure();
}

/// The server responded with an error status code.
class ServerFailure extends Failure {
  const ServerFailure({this.statusCode});

  final int? statusCode;

  @override
  List<Object?> get props => [statusCode];
}

/// Offline with no cached data available to fall back on.
class CacheFailure extends Failure {
  const CacheFailure();
}

/// An unexpected, unclassified error.
class UnknownFailure extends Failure {
  const UnknownFailure();
}
