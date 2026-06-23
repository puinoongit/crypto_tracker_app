import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:crypto_tracker_app/core/localization/generated/app_localizations.dart';
import 'package:crypto_tracker_app/core/settings/settings_controller.dart';

/// Bottom sheet for switching theme mode and app language.
///
/// Both selections persist immediately via [SettingsController]; the UI reflects
/// the change on the next frame because it watches the same provider.
class SettingsSheet extends ConsumerWidget {
  const SettingsSheet({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (_) => const SettingsSheet(),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final settings = ref.watch(settingsControllerProvider);
    final controller = ref.read(settingsControllerProvider.notifier);
    final theme = Theme.of(context);

    return SafeArea(
      child: SizedBox(
        width: double.infinity,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(l10n.settingsTheme, style: theme.textTheme.titleSmall),
              const SizedBox(height: 8),
              SegmentedButton<ThemeMode>(
                segments: [
                  ButtonSegment(
                    value: ThemeMode.system,
                    label: Text(l10n.themeSystem),
                    icon: const Icon(Icons.brightness_auto_rounded),
                  ),
                  ButtonSegment(
                    value: ThemeMode.light,
                    label: Text(l10n.themeLight),
                    icon: const Icon(Icons.light_mode_rounded),
                  ),
                  ButtonSegment(
                    value: ThemeMode.dark,
                    label: Text(l10n.themeDark),
                    icon: const Icon(Icons.dark_mode_rounded),
                  ),
                ],
                selected: {settings.themeMode},
                onSelectionChanged: (s) => controller.setThemeMode(s.first),
              ),
              const SizedBox(height: 24),
              Text(l10n.settingsLanguage, style: theme.textTheme.titleSmall),
              const SizedBox(height: 8),
              SegmentedButton<String>(
                segments: const [
                  ButtonSegment(value: 'system', label: Text('System')),
                  ButtonSegment(value: 'en', label: Text('English')),
                  ButtonSegment(value: 'th', label: Text('ไทย')),
                ],
                selected: {settings.locale?.languageCode ?? 'system'},
                onSelectionChanged: (s) {
                  final code = s.first;
                  controller.setLocale(code == 'system' ? null : Locale(code));
                },
              ),
              const SizedBox(height: 24),
              Text(l10n.settingsLiveUpdates, style: theme.textTheme.titleSmall),
              const SizedBox(height: 4),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(l10n.settingsLiveUpdatesTitle),
                subtitle: Text(l10n.settingsLiveUpdatesSubtitle),
                value: settings.livePriceUpdates,
                onChanged: controller.setLivePriceUpdates,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
