import 'package:crypto_tracker_app/core/error/failure.dart';

/// A lightweight, dependency-free `Either`-style type.
///
/// Repositories and use cases return `Result<T>` instead of throwing, forcing
/// callers to handle both the success and the [Failure] path explicitly. This
/// keeps error handling exhaustive (via `switch`) and the UI free of try/catch.
sealed class Result<T> {
  const Result();

  /// Convenience constructors.
  const factory Result.ok(T value) = Ok<T>;
  const factory Result.err(Failure failure) = Err<T>;

  bool get isOk => this is Ok<T>;
  bool get isErr => this is Err<T>;

  /// Folds both branches into a single value of type [R].
  R fold<R>(R Function(Failure failure) onErr, R Function(T value) onOk) {
    return switch (this) {
      Ok<T>(:final value) => onOk(value),
      Err<T>(:final failure) => onErr(failure),
    };
  }

  /// Returns the success value or `null` if this is an error.
  T? get valueOrNull => switch (this) {
    Ok<T>(:final value) => value,
    Err<T>() => null,
  };
}

class Ok<T> extends Result<T> {
  const Ok(this.value);
  final T value;
}

class Err<T> extends Result<T> {
  const Err(this.failure);
  final Failure failure;
}
