import 'package:crypto_tracker_app/core/widgets/refresh_status_banner.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/pump_app.dart';

void main() {
  testWidgets('shows localized updating copy when visible', (tester) async {
    await pumpApp(tester, const RefreshStatusBanner(visible: true));

    expect(find.textContaining('SYNCING'), findsOneWidget);
  });

  testWidgets('hides when not visible', (tester) async {
    await pumpApp(tester, const RefreshStatusBanner(visible: false));

    expect(find.textContaining('SYNCING'), findsNothing);
  });
}
