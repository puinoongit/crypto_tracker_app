import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:crypto_tracker_app/core/network/network_info.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockConnectivity extends Mock implements Connectivity {}

void main() {
  late MockConnectivity connectivity;
  late NetworkInfoImpl networkInfo;

  setUp(() {
    connectivity = MockConnectivity();
    networkInfo = NetworkInfoImpl(connectivity);
  });

  test('isConnected is true when any non-none result is present', () async {
    when(
      () => connectivity.checkConnectivity(),
    ).thenAnswer((_) async => [ConnectivityResult.wifi]);
    expect(await networkInfo.isConnected, isTrue);
  });

  test('isConnected is false when only none is present', () async {
    when(
      () => connectivity.checkConnectivity(),
    ).thenAnswer((_) async => [ConnectivityResult.none]);
    expect(await networkInfo.isConnected, isFalse);
  });

  test('onStatusChange maps the connectivity stream to booleans', () async {
    when(() => connectivity.onConnectivityChanged).thenAnswer(
      (_) => Stream.fromIterable([
        [ConnectivityResult.none],
        [ConnectivityResult.mobile],
      ]),
    );

    expect(await networkInfo.onStatusChange.toList(), [false, true]);
  });
}
