import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';

import 'package:crypto_tracker_app/core/providers/core_providers.dart';

/// Immutable app-wide preferences.
class SettingsState extends Equatable {
  const SettingsState({
    this.themeMode = ThemeMode.system,
    this.locale,
    this.livePriceUpdates = true,
  });

  /// `null` locale means "follow the system locale".
  final ThemeMode themeMode;
  final Locale? locale;

  /// Foreground polling on the Market tab (90 s). Pull-to-refresh still works.
  final bool livePriceUpdates;

  SettingsState copyWith({
    ThemeMode? themeMode,
    Locale? Function()? locale,
    bool? livePriceUpdates,
  }) {
    return SettingsState(
      themeMode: themeMode ?? this.themeMode,
      locale: locale != null ? locale() : this.locale,
      livePriceUpdates: livePriceUpdates ?? this.livePriceUpdates,
    );
  }

  @override
  List<Object?> get props => [themeMode, locale, livePriceUpdates];
}

/// Persists and exposes user preferences (theme + language).
class SettingsController extends Notifier<SettingsState> {
  static const _themeKey = 'theme_mode';
  static const _localeKey = 'locale';
  static const _livePriceKey = 'live_price_updates';

  late final Box<String> _box;

  @override
  SettingsState build() {
    _box = ref.watch(settingsBoxProvider);
    return SettingsState(
      themeMode: _readThemeMode(),
      locale: _readLocale(),
      livePriceUpdates: _readLivePriceUpdates(),
    );
  }

  ThemeMode _readThemeMode() {
    return switch (_box.get(_themeKey)) {
      'light' => ThemeMode.light,
      'dark' => ThemeMode.dark,
      _ => ThemeMode.system,
    };
  }

  Locale? _readLocale() {
    final code = _box.get(_localeKey);
    return code == null ? null : Locale(code);
  }

  bool _readLivePriceUpdates() => _box.get(_livePriceKey) != 'false';

  Future<void> setThemeMode(ThemeMode mode) async {
    state = state.copyWith(themeMode: mode);
    await _box.put(_themeKey, mode.name);
  }

  Future<void> setLocale(Locale? locale) async {
    state = state.copyWith(locale: () => locale);
    if (locale == null) {
      await _box.delete(_localeKey);
    } else {
      await _box.put(_localeKey, locale.languageCode);
    }
  }

  Future<void> setLivePriceUpdates(bool enabled) async {
    state = state.copyWith(livePriceUpdates: enabled);
    await _box.put(_livePriceKey, enabled ? 'true' : 'false');
  }
}

final settingsControllerProvider =
    NotifierProvider<SettingsController, SettingsState>(SettingsController.new);
