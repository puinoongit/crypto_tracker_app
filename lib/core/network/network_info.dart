import 'package:connectivity_plus/connectivity_plus.dart';

/// Abstraction over the platform's connectivity state.
///
/// Exposed as an interface so repositories depend on the *contract* rather than
/// `connectivity_plus` directly — this keeps the data layer testable (the impl
/// is trivially mockable) and swappable.
abstract interface class NetworkInfo {
  /// Whether the device currently has a network connection.
  Future<bool> get isConnected;

  /// Emits `true`/`false` as connectivity changes. Used to drive the offline
  /// indicator without polling.
  Stream<bool> get onStatusChange;
}

class NetworkInfoImpl implements NetworkInfo {
  NetworkInfoImpl(this._connectivity);

  final Connectivity _connectivity;

  static bool _hasConnection(List<ConnectivityResult> results) {
    return results.any((r) => r != ConnectivityResult.none);
  }

  @override
  Future<bool> get isConnected async {
    final results = await _connectivity.checkConnectivity();
    return _hasConnection(results);
  }

  @override
  Stream<bool> get onStatusChange {
    return _connectivity.onConnectivityChanged.map(_hasConnection);
  }
}
