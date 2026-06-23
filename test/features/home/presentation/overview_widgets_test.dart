import 'package:crypto_tracker_app/features/home/presentation/view/widgets/global_market_card.dart';
import 'package:crypto_tracker_app/features/home/presentation/view/widgets/trending_section.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/fixtures.dart';
import '../../../helpers/pump_app.dart';

void main() {
  testWidgets('GlobalMarketCard shows compacted cap, volume, and change', (
    tester,
  ) async {
    await pumpApp(
      tester,
      Scaffold(body: GlobalMarketCard(global: buildGlobalMarket())),
    );
    await tester.pump(); // start count-up
    await tester.pump(const Duration(seconds: 1)); // finish count-up

    // Deterministic, locale-independent assertions: labels, the 24h change,
    // and that values compact to trillions/billions.
    expect(find.text('MARKET CAP · 24H'), findsOneWidget);
    expect(find.text('VOLUME · 24H'), findsOneWidget);
    expect(find.text('-0.42%'), findsOneWidget);
    expect(find.textContaining('T'), findsWidgets);
    expect(find.textContaining('B'), findsWidgets);
  });

  testWidgets('TrendingSection renders a card per trending coin', (
    tester,
  ) async {
    await pumpApp(
      tester,
      Scaffold(body: TrendingSection(coins: buildTrendingCoins())),
    );
    await tester.pump();

    expect(find.text('T0'), findsOneWidget); // symbol uppercased
    expect(find.text('#100'), findsOneWidget);
    expect(find.text('+5.00%'), findsWidgets);
  });
}
