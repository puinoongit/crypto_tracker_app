import 'package:crypto_tracker_app/core/error/failure.dart';
import 'package:crypto_tracker_app/core/utils/result.dart';
import 'package:crypto_tracker_app/features/coin_detail/domain/entity/coin_detail.dart';
import 'package:crypto_tracker_app/features/coin_detail/presentation/coin_detail_providers.dart';
import 'package:crypto_tracker_app/features/coin_detail/presentation/view/coin_detail_screen.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:crypto_tracker_app/features/coin_detail/presentation/view/widgets/coin_detail_skeleton.dart';

import '../../../helpers/fixtures.dart';
import '../../../helpers/mocks.dart';
import '../../../helpers/pump_app.dart';

void main() {
  late MockGetCoinDetail useCase;

  setUpAll(registerCommonFallbacks);
  setUp(() {
    useCase = MockGetCoinDetail();
    when(() => useCase.peekCached(any())).thenReturn(null);
  });

  Future<void> pumpDetail(WidgetTester tester) async {
    await pumpApp(
      tester,
      const CoinDetailScreen(coinId: 'bitcoin', fallbackName: 'Bitcoin'),
      overrides: [getCoinDetailUseCaseProvider.overrideWithValue(useCase)],
    );
  }

  testWidgets('renders price and stat labels', (tester) async {
    when(
      () => useCase(any()),
    ).thenAnswer((_) async => Result.ok(buildCoinDetail()));

    await pumpDetail(tester);
    expect(find.byType(CoinDetailSkeleton), findsOneWidget);

    await tester.pump(); // resolve load
    await tester.pump(const Duration(seconds: 1)); // finish price count-up

    expect(find.text(r'$50,000.00'), findsOneWidget);
    // Market cap stat label is shown near the top of the detail.
    expect(find.text('Market Cap'), findsOneWidget);
  });

  testWidgets('shows an error view with retry on failure', (tester) async {
    when(
      () => useCase(any()),
    ).thenAnswer((_) async => const Result<CoinDetail>.err(TimeoutFailure()));

    await pumpDetail(tester);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));

    expect(find.text('Request timed out'), findsOneWidget);
    expect(find.text('Retry'), findsOneWidget);
  });
}
