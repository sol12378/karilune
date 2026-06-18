import 'package:flutter/material.dart';

import '../../models/ad.dart';
import '../../theme/app_theme.dart';
import '../ad_card_grid_shell.dart';
import '../ad_thumbnail.dart';
import '../motion/hover_lift_card.dart';

const double kFeaturedAdCardWidth = 380;
const double kFeaturedAdImageHeight = 180;

class FeaturedAdCard extends StatelessWidget {
  const FeaturedAdCard({
    super.key,
    required this.ad,
    this.onTap,
    this.width = kFeaturedAdCardWidth,
  });

  final Ad ad;
  final VoidCallback? onTap;
  final double width;

  @override
  Widget build(BuildContext context) {
    final remainingDays = ad.endDate.difference(DateTime.now()).inDays;

    return SizedBox(
      width: width,
      child: HoverLiftCard(
        onTap: onTap,
        child: Card(
          margin: EdgeInsets.zero,
          clipBehavior: Clip.antiAlias,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Stack(
                children: [
                  AdThumbnail(
                    assetPath: ad.thumbnailAssetPath,
                    networkUrl: ad.thumbnailUrl,
                    width: double.infinity,
                    height: kFeaturedAdImageHeight,
                    borderRadius: 0,
                  ),
                  if (ad.hasSpotlightOption)
                    const Positioned(
                      top: 8,
                      right: 8,
                      child: AdCardBadge(label: '注目', color: AppColors.accent),
                    ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      ad.companyName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: Colors.grey.shade600,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      ad.catchCopy,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            height: 1.3,
                          ),
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 12,
                      runSpacing: 4,
                      children: [
                        _MetaItem(
                          icon: Icons.sell_outlined,
                          label: ad.category,
                        ),
                        _MetaItem(
                          icon: Icons.place_outlined,
                          label: ad.prefecture,
                        ),
                        _MetaItem(
                          icon: Icons.schedule_outlined,
                          label: '残り${remainingDays.clamp(0, 999)}日',
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Align(
                      alignment: Alignment.centerRight,
                      child: Text(
                        '詳細を見る →',
                        style: Theme.of(context).textTheme.labelMedium?.copyWith(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MetaItem extends StatelessWidget {
  const _MetaItem({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: Colors.grey.shade600),
        const SizedBox(width: 4),
        Text(
          label,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: Colors.grey.shade700,
              ),
        ),
      ],
    );
  }
}
