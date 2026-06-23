import 'package:crypto_tracker_app/core/error/failure.dart';
import 'generated/app_localizations.dart';

/// A localized, user-presentable view of a [Failure].
class LocalizedFailure {
  const LocalizedFailure({required this.title, required this.message});
  final String title;
  final String message;
}

/// Turns a domain [Failure] into localized copy. This is the single bridge
/// between error types and what the user actually reads — no other layer should
/// hardcode error strings.
extension FailureLocalizer on AppLocalizations {
  LocalizedFailure localizeFailure(Failure failure) {
    return switch (failure) {
      NoInternetFailure() => LocalizedFailure(
        title: errorNoInternetTitle,
        message: errorNoInternetMessage,
      ),
      TimeoutFailure() => LocalizedFailure(
        title: errorTimeoutTitle,
        message: errorTimeoutMessage,
      ),
      ServerFailure() => LocalizedFailure(
        title: errorServerTitle,
        message: errorServerMessage,
      ),
      CacheFailure() => LocalizedFailure(
        title: errorCacheTitle,
        message: errorCacheMessage,
      ),
      UnknownFailure() => LocalizedFailure(
        title: errorUnknownTitle,
        message: errorUnknownMessage,
      ),
    };
  }
}
