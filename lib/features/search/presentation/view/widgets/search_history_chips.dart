import 'package:flutter/material.dart';

import 'package:crypto_tracker_app/core/localization/generated/app_localizations.dart';

/// Recent search queries shown as tappable chips below the search field.
class SearchHistoryChips extends StatelessWidget {
  const SearchHistoryChips({
    required this.queries,
    required this.onSelected,
    required this.onClear,
    super.key,
  });

  final List<String> queries;
  final ValueChanged<String> onSelected;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    if (queries.isEmpty) return const SizedBox.shrink();

    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  l10n.searchHistoryTitle,
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
              TextButton(
                onPressed: onClear,
                style: TextButton.styleFrom(
                  visualDensity: VisualDensity.compact,
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                ),
                child: Text(l10n.searchHistoryClear),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final query in queries)
                ActionChip(
                  label: Text(query),
                  avatar: Icon(
                    Icons.history_rounded,
                    size: 18,
                    color: theme.colorScheme.primary,
                  ),
                  onPressed: () => onSelected(query),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
