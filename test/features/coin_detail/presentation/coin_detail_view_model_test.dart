import 'package:crypto_tracker_app/core/error/failure.dart';
import 'package:crypto_tracker_app/core/utils/result.dart';
import 'package:crypto_tracker_app/features/coin_detail/domain/entity/coin_detail.dart';
import 'package:crypto_tracker_app/features/coin_detail/presentation/coin_detail_providers.dart';
import 'package:crypto_tracker_app/features/coin_detail/presentation/state/coin_detail_state.dart';
import 'package:crypto_tracker_app/features/coin_detail/presentation/view_model/coin_detail_view_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../helpers/fixtures.dart';
import '../../../helpers/mocks.dart';

void main() {
  late MockGetCoinDetail useCase;

  setUpAll(registerCommonFallbacks);
  setUp(() {
    useCase = MockGetCoinDetail();
    when(() => useCase.peekCached(any())).thenReturn(null);
  });

  ProviderContainer makeContainer() {
    final container = ProviderContainer(
      overrides: [getCoinDetailUseCaseProvider.overrideWithValue(useCase)],
    );
    addTearDown(container.dispose);
    return container;
  }

  void keepAlive(ProviderContainer container, String coinId) {
    final sub = container.listen(
      coinDetailViewModelProvider(coinId),
      (_, _) {},
    );
    addTearDown(sub.close);
  }

  test('loads detail successfully on build', () async {
    when(
      () => useCase(any()),
    ).thenAnswer((_) async => Result.ok(buildCoinDetail()));

    final container = makeContainer();
    keepAlive(container, 'bitcoin');
    container.read(coinDetailViewModelProvider('bitcoin'));
    await pumpEventQueue();

    final state = container.read(coinDetailViewModelProvider('bitcoin'));
    expect(state.status, CoinDetailStatus.success);
    expect(state.detail?.name, 'Bitcoin');
  });

  test('emits error state on failure when no cache exists', () async {
    when(
      () => useCase(any()),
    ).thenAnswer((_) async => const Result<CoinDetail>.err(TimeoutFailure()));

    final container = makeContainer();
    keepAlive(container, 'bitcoin');
    container.read(coinDetailViewModelProvider('bitcoin'));
    await pumpEventQueue();

    final state = container.read(coinDetailViewModelProvider('bitcoin'));
    expect(state.status, CoinDetailStatus.error);
    expect(state.failure, isA<TimeoutFailure>());
  });

  test('keeps stale detail visible when refresh fails', () async {
    final stale = buildCoinDetail();
    when(() => useCase.peekCached('bitcoin')).thenReturn(stale);
    when(
      () => useCase(any()),
    ).thenAnswer((_) async => const Result<CoinDetail>.err(TimeoutFailure()));

    final container = makeContainer();
    keepAlive(container, 'bitcoin');
    container.read(coinDetailViewModelProvider('bitcoin'));
    await pumpEventQueue();

    final state = container.read(coinDetailViewModelProvider('bitcoin'));
    expect(state.status, CoinDetailStatus.success);
    expect(state.detail?.name, 'Bitcoin');
    expect(state.failure, isNull);
  });
}
