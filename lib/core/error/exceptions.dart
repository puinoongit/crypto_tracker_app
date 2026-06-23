/// Low-level exceptions thrown by the **data layer** (data sources).
///
/// These are intentionally internal: they never cross into the presentation
/// layer. Repositories catch them and translate them into [Failure]s so the
/// UI only ever deals with domain-friendly error types.
library;

/// Thrown when the device has no network connectivity.
class NoInternetException implements Exception {
  const NoInternetException();
}

/// Thrown when a request or response exceeds the configured timeout.
class TimeoutException implements Exception {
  const TimeoutException();
}

/// Thrown when the server responds with a non-2xx status code.
class ServerException implements Exception {
  const ServerException({this.statusCode, this.message});

  final int? statusCode;
  final String? message;
}

/// Thrown when the local cache is empty or could not be read.
class CacheException implements Exception {
  const CacheException([this.message]);

  final String? message;
}

/// Thrown for any unclassified/unexpected error in the data layer.
class UnknownException implements Exception {
  const UnknownException([this.message]);

  final String? message;
}
