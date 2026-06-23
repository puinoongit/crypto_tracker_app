import 'package:crypto_tracker_app/core/utils/result.dart';

/// Contract for a single unit of application business logic.
///
/// Use cases keep the domain layer's intent explicit and the ViewModels thin:
/// a ViewModel orchestrates use cases, it doesn't talk to repositories directly.
abstract interface class UseCase<Out, In> {
  Future<Result<Out>> call(In params);
}

/// Marker for use cases that take no arguments.
class NoParams {
  const NoParams();
}
