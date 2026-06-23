import 'package:flutter/material.dart';

/// A labeled statistic card used in the coin detail metrics grid.
///
/// Optionally shows a small colored [subValue] beneath the value — used for the
/// ATH/ATL percentage deltas.
class StatTile extends StatelessWidget {
  const StatTile({
    required this.label,
    required this.value,
    this.subValue,
    this.subValueColor,
    super.key,
  });

  final String label;
  final String value;
  final String? subValue;
  final Color? subValueColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            if (subValue != null) ...[
              const SizedBox(height: 2),
              Text(
                subValue!,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: subValueColor ?? theme.colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
