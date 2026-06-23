import 'package:crypto_tracker_app/core/widgets/pull_to_refresh_list.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/pump_app.dart';

void main() {
  List<Widget> listSlivers() {
    return [
      SliverList.builder(
        itemCount: 20,
        itemBuilder: (context, index) => ListTile(title: Text('Coin $index')),
      ),
    ];
  }

  Future<void> pumpList(
    WidgetTester tester, {
    required bool isRefreshing,
    required Future<void> Function() onRefresh,
  }) {
    return pumpApp(
      tester,
      Scaffold(
        body: PullToRefreshList(
          isRefreshing: isRefreshing,
          onRefresh: onRefresh,
          slivers: listSlivers(),
        ),
      ),
    );
  }

  testWidgets('shows the status banner when isRefreshing is true', (
    tester,
  ) async {
    await pumpList(tester, isRefreshing: true, onRefresh: () async {});

    expect(find.textContaining('SYNCING'), findsOneWidget);
  });

  testWidgets('hides the status banner when isRefreshing is false', (
    tester,
  ) async {
    await pumpList(tester, isRefreshing: false, onRefresh: () async {});

    expect(find.textContaining('SYNCING'), findsNothing);
  });

  testWidgets('uses Cupertino pull-to-refresh scroll view', (tester) async {
    await pumpList(tester, isRefreshing: false, onRefresh: () async {});

    expect(find.byType(CustomScrollView), findsOneWidget);
    expect(find.byType(RefreshIndicator), findsNothing);
  });

  testWidgets('shows the banner only while isRefreshing is true', (
    tester,
  ) async {
    await pumpApp(tester, const Scaffold(body: _RefreshHarness()));

    expect(find.textContaining('SYNCING'), findsNothing);

    await tester.tap(find.text('Run refresh'));
    await tester.pump();
    expect(find.textContaining('SYNCING'), findsOneWidget);

    await tester.pump(const Duration(milliseconds: 60));
    await tester.pump();
    expect(find.textContaining('SYNCING'), findsNothing);
  });
}

/// Mirrors how screens wire [PullToRefreshList] to a ViewModel refresh flag.
class _RefreshHarness extends StatefulWidget {
  const _RefreshHarness();

  @override
  State<_RefreshHarness> createState() => _RefreshHarnessState();
}

class _RefreshHarnessState extends State<_RefreshHarness> {
  var _isRefreshing = false;

  Future<void> _handleRefresh() async {
    setState(() => _isRefreshing = true);
    await Future<void>.delayed(const Duration(milliseconds: 50));
    if (mounted) setState(() => _isRefreshing = false);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextButton(
          onPressed: _isRefreshing ? null : _handleRefresh,
          child: const Text('Run refresh'),
        ),
        Expanded(
          child: PullToRefreshList(
            isRefreshing: _isRefreshing,
            onRefresh: _handleRefresh,
            slivers: [
              SliverList.builder(
                itemCount: 12,
                itemBuilder: (context, index) =>
                    ListTile(title: Text('Coin $index')),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
