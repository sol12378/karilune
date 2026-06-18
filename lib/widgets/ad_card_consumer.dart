import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/ad.dart';
import '../providers/favorites_provider.dart';
import '../theme/motion.dart';
import '../utils/date_formats.dart';
import '../theme/app_theme.dart';
import 'ad_card_grid_shell.dart';
import 'motion/hover_lift_card.dart';

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
    final isFavorite = ref.watch(isFavoriteProvider(ad.id));
    final remainingDays = ad.endDate.difference(DateTime.now()).inDays;

    return HoverLiftCard(
      child: AdCardGridShell(
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
                  AppDateFormats.monthDay.format(ad.startDate),
                  AppDateFormats.monthDay.format(ad.endDate),
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
                AnimatedSwitcher(
                  duration: AppMotion.fast,
                  transitionBuilder: (child, animation) => ScaleTransition(
                    scale: animation,
                    child: child,
                  ),
                  child: Icon(
                    isFavorite ? Icons.favorite : Icons.favorite_border,
                    key: ValueKey(isFavorite),
                    size: 18,
                    color: isFavorite ? Colors.red : Colors.grey,
                  ),
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
      ),
    );
  }
}
