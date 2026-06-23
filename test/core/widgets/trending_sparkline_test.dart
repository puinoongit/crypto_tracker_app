import 'package:crypto_tracker_app/core/widgets/trending_sparkline.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('renders an empty placeholder when url is blank', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: TrendingSparkline(url: '', color: Colors.green, width: 120),
        ),
      ),
    );

    expect(find.byType(TrendingSparkline), findsOneWidget);
    expect(tester.getSize(find.byType(TrendingSparkline)), const Size(120, 22));
  });
}
