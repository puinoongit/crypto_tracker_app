import 'package:flutter/material.dart';

import 'package:crypto_tracker_app/core/error/failure.dart';
import 'package:crypto_tracker_app/core/localization/failure_localizer.dart';
import 'package:crypto_tracker_app/core/localization/generated/app_localizations.dart';

/// Full-screen, user-friendly error state with a retry affordance.
///
/// Takes a domain [Failure] and localizes it here, so screens never embed raw
/// error strings. An appropriate icon is chosen per failure kind.
class ErrorView extends StatelessWidget {
  const ErrorView({required this.failure, required this.onRetry, super.key});

  final Failure failure;
  final VoidCallback onRetry;

  IconData get _icon => switch (failure) {
    NoInternetFailure() => Icons.wifi_off_rounded,
    TimeoutFailure() => Icons.timer_off_rounded,
    CacheFailure() => Icons.cloud_off_rounded,
    ServerFailure() => Icons.cloud_off_rounded,
    UnknownFailure() => Icons.error_outline_rounded,
  };

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final localized = l10n.localizeFailure(failure);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(_icon, size: 56, color: theme.colorScheme.outline),
            const SizedBox(height: 16),
            Text(
              localized.title,
              style: theme.textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              localized.message,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            FilledButton.tonalIcon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded),
              label: Text(l10n.retry),
            ),
          ],
        ),
      ),
    );
  }
}
