import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/ad.dart';
import '../theme/app_theme.dart';
import 'ad_card_grid_shell.dart';

class AdCardDistributor extends StatelessWidget {
  const AdCardDistributor({
    super.key,
    required this.ad,
    this.onTap,
    this.onToggleDistribute,
  });

  final Ad ad;
  final VoidCallback? onTap;
  final VoidCallback? onToggleDistribute;

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('MM/dd');

    return AdCardGridShell(
      assetPath: ad.thumbnailAssetPath,
      networkUrl: ad.thumbnailUrl,
      onTap: onTap,
      thumbnailOverlays: [
        if (ad.isDistributing)
          const Positioned(
            top: 6,
            right: 6,
            child: AdCardBadge(label: '配信中', color: AppColors.distributing),
          ),
      ],
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AdCardTitleBlock(
              companyName: ad.companyName,
              catchCopy: ad.catchCopy,
              catchCopyMaxLines: 2,
            ),
            const SizedBox(height: 6),
            AdCardSummaryRow(
              labels: const ['開始', '終了', '参照'],
              values: [
                dateFormat.format(ad.startDate),
                dateFormat.format(ad.endDate),
                '${ad.viewCount}',
              ],
            ),
          ],
        ),
        SizedBox(
          width: double.infinity,
          child: FilledButton.tonal(
            onPressed: onToggleDistribute,
            style: FilledButton.styleFrom(
              visualDensity: VisualDensity.compact,
              backgroundColor: ad.isDistributing
                  ? AppColors.distributing.withValues(alpha: 0.15)
                  : AppColors.primary.withValues(alpha: 0.1),
              foregroundColor:
                  ad.isDistributing ? AppColors.distributing : AppColors.primary,
            ),
            child: Text(
              ad.isDistributing ? '配信停止' : '配信する',
              style: const TextStyle(fontSize: 12),
            ),
          ),
        ),
      ],
    );
  }
}
