import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../models/ad.dart';
import '../providers/favorites_provider.dart';
import '../theme/app_theme.dart';
import 'ad_card_grid_shell.dart';

class AdCardConsumer extends ConsumerWidget {
  const AdCardConsumer({
    super.key,
    required this.ad,
    this.onTap,
  });

  final Ad ad;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dateFormat = DateFormat('MM/dd');
    final isFavorite = ref.watch(favoritesProvider).contains(ad.id);
    final remainingDays = ad.endDate.difference(DateTime.now()).inDays;

    return AdCardGridShell(
      assetPath: ad.thumbnailAssetPath,
      networkUrl: ad.thumbnailUrl,
      onTap: onTap,
      thumbnailOverlays: [
        if (ad.hasSpotlightOption)
          const Positioned(
            top: 6,
            right: 6,
            child: AdCardBadge(label: '注目', color: AppColors.accent),
          ),
      ],
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                AdCardBadge(
                  label: ad.category,
                  color: AppColors.primary.withValues(alpha: 0.85),
                ),
              ],
            ),
            const SizedBox(height: 4),
            AdCardTitleBlock(
              companyName: ad.companyName,
              catchCopy: ad.catchCopy,
              catchCopyMaxLines: 1,
            ),
            const SizedBox(height: 6),
            AdCardSummaryRow(
              labels: const ['開始', '終了', '残り'],
              values: [
                dateFormat.format(ad.startDate),
                dateFormat.format(ad.endDate),
                '${remainingDays.clamp(0, 999)}日',
              ],
            ),
          ],
        ),
        InkWell(
          onTap: () => ref.read(favoritesProvider.notifier).toggle(ad.id),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                isFavorite ? Icons.favorite : Icons.favorite_border,
                size: 18,
                color: isFavorite ? Colors.red : Colors.grey,
              ),
              const SizedBox(width: 4),
              Text(
                isFavorite ? 'お気に入り済み' : 'お気に入り',
                style: Theme.of(context).textTheme.labelSmall,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
