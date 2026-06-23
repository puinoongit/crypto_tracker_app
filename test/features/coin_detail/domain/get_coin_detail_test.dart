import 'package:crypto_tracker_app/core/utils/result.dart';
import 'package:crypto_tracker_app/features/coin_detail/domain/usecase/get_coin_detail.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../helpers/fixtures.dart';
import '../../../helpers/mocks.dart';

void main() {
  late MockCoinDetailRepository repository;
  late GetCoinDetail useCase;

  setUp(() {
    repository = MockCoinDetailRepository();
    useCase = GetCoinDetail(repository);
  });

  test('forwards coinId and forceRefresh to the repository', () async {
    when(
      () => repository.getCoinDetail(
        any(),
        forceRefresh: any(named: 'forceRefresh'),
      ),
    ).thenAnswer((_) async => Result.ok(buildCoinDetail()));

    final result = await useCase(
      const CoinDetailParams(coinId: 'bitcoin', forceRefresh: true),
    );

    expect(result.valueOrNull?.id, 'bitcoin');
    verify(
      () => repository.getCoinDetail('bitcoin', forceRefresh: true),
    ).called(1);
  });
}
