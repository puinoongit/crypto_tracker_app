import 'dart:io';

import 'package:battery_plus/battery_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_displaymode/flutter_displaymode.dart';

final Battery _battery = Battery();

/// Aligns Android display refresh rate with the user's system power profile.
///
/// - **Battery saver / Low Power Mode** → lowest refresh rate (save power).
/// - **Normal mode** → highest refresh rate at the current resolution (smooth).
///
/// iOS follows the system automatically: [CADisableMinimumFrameDurationOnPhone] in
/// `ios/Runner/Info.plist` removes Flutter's 60 Hz cap, and iOS caps ProMotion
/// when Low Power Mode is on.
Future<void> syncDisplayRefreshRateWithSystem() async {
  if (kIsWeb || !Platform.isAndroid) return;

  try {
    final powerSave = await _battery.isInBatterySaveMode;
    if (powerSave) {
      await FlutterDisplayMode.setLowRefreshRate();
    } else {
      await FlutterDisplayMode.setHighRefreshRate();
    }
  } catch (_) {
    // Unsupported device — keep the OS default.
  }
}

/// Re-syncs refresh rate when the app returns to the foreground so toggling
/// Battery Saver / Low Power Mode applies without restarting the app.
class DisplayRefreshRateLifecycleSync extends StatefulWidget {
  const DisplayRefreshRateLifecycleSync({required this.child, super.key});

  final Widget child;

  @override
  State<DisplayRefreshRateLifecycleSync> createState() =>
      _DisplayRefreshRateLifecycleSyncState();
}

class _DisplayRefreshRateLifecycleSyncState
    extends State<DisplayRefreshRateLifecycleSync>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      syncDisplayRefreshRateWithSystem();
    }
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
