import 'dart:async';
import 'package:flutter/foundation.dart';

/// Debounces rapid successive calls, running [action] only after [delay] has
/// elapsed without a new call. Used for search-as-you-type to avoid filtering
/// on every keystroke.
class Debouncer {
  Debouncer({this.delay = const Duration(milliseconds: 300)});

  final Duration delay;
  Timer? _timer;

  void run(VoidCallback action) {
    _timer?.cancel();
    _timer = Timer(delay, action);
  }

  /// Cancels any pending action. Call from `dispose()` to avoid leaks.
  void dispose() => _timer?.cancel();
}
