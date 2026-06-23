import 'package:crypto_tracker_app/core/error/failure.dart';
import 'package:crypto_tracker_app/core/utils/result.dart';
import 'package:crypto_tracker_app/features/home/domain/entity/coin.dart';
import 'package:crypto_tracker_app/features/home/presentation/home_providers.dart';
import 'package:crypto_tracker_app/features/home/presentation/view/home_screen.dart';
import 'package:crypto_tracker_app/features/home/presentation/view/widgets/market_header_skeletons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:crypto_tracker_app/core/widgets/sparkline_chart.dart';
import 'package:crypto_tracker_app/features/home/presentation/view/widgets/market_list_skeleton.dart';

import '../../../helpers/fixtures.dart';
import '../../../helpers/mocks.dart';
import '../../../helpers/pump_app.dart';

void main() {
  late MockGetMarketCoins useCase;

  setUpAll(registerCommonFallbacks);
  setUp(() {
    useCase = MockGetMarketCoins();
  });

  Future<void> pumpHome(WidgetTester tester) async {
    await pumpApp(
      tester,
      const Scaffold(body: HomeScreen()),
      overrides: [getMarketCoinsUseCaseProvider.overrideWithValue(useCase)],
    );
  }

  testWidgets('loads header before the coin list', (tester) async {
    when(() => useCase(any())).thenAnswer((_) async {
      await Future<void>.delayed(const Duration(milliseconds: 200));
      return Result.ok(buildCoins(5));
    });

    await pumpHome(tester);
    expect(find.byType(GlobalMarketCardSkeleton), findsOneWidget);
    expect(find.byType(MarketListSkeleton), findsNothing);

    await tester.pump();
    await tester.pump();

    expect(find.byType(MarketListSkeleton), findsOneWidget);
    expect(find.text('Coin 1'), findsNothing);

    await tester.pump(const Duration(milliseconds: 250));

    expect(find.byType(MarketListSkeleton), findsNothing);
    expect(find.text('Coin 1'), findsOneWidget);
    expect(find.text('Coin 5'), findsOneWidget);
    expect(find.byType(SparklineChart), findsWidgets);
  });

  testWidgets('renders an error view with retry on failure', (tester) async {
    when(() => useCase(any())).thenAnswer(
      (_) async => const Result<List<Coin>>.err(NoInternetFailure()),
    );

    await pumpHome(tester);
    await flushMarketJourney(tester);
    await tester.pump(const Duration(milliseconds: 50));

    expect(find.text('No internet connection'), findsOneWidget);
    expect(find.text('Retry'), findsOneWidget);
  });

  testWidgets('does not show a search field on the market tab', (tester) async {
    when(
      () => useCase(any()),
    ).thenAnswer((_) async => Result.ok(buildCoins(5)));

    await pumpHome(tester);
    await flushMarketJourney(tester);
    await tester.pump(const Duration(milliseconds: 50));

    expect(find.byType(TextField), findsNothing);
  });
}
