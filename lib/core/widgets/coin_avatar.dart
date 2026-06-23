import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

/// Circular coin logo with disk/memory caching and graceful placeholders.
///
/// Decodes logos at display size only so the in-memory image cache stays small
/// on low-RAM devices.
class CoinAvatar extends StatelessWidget {
  const CoinAvatar({required this.imageUrl, this.size = 40, super.key});

  final String imageUrl;
  final double size;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final fallback = CircleAvatar(
      radius: size / 2,
      backgroundColor: scheme.surfaceContainerHighest,
      child: Icon(
        Icons.currency_bitcoin,
        size: size * 0.5,
        color: scheme.outline,
      ),
    );

    if (imageUrl.isEmpty) return fallback;

    final cachePx = (size * MediaQuery.devicePixelRatioOf(context)).round();

    return ClipOval(
      child: CachedNetworkImage(
        imageUrl: imageUrl,
        width: size,
        height: size,
        fit: BoxFit.cover,
        memCacheWidth: cachePx,
        memCacheHeight: cachePx,
        maxWidthDiskCache: cachePx,
        maxHeightDiskCache: cachePx,
        placeholder: (_, _) => SizedBox(
          width: size,
          height: size,
          child: ColoredBox(color: scheme.surfaceContainerHighest),
        ),
        errorWidget: (_, _, _) => fallback,
      ),
    );
  }
}
