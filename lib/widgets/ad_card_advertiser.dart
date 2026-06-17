import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/ad.dart';
import '../theme/app_theme.dart';
import 'ad_card_grid_shell.dart';

class AdCardAdvertiser extends StatelessWidget {
  const AdCardAdvertiser({
    super.key,
    required this.ad,
    this.onTap,
    this.onDetail,
    this.onEdit,
  });

  final Ad ad;
  final VoidCallback? onTap;
  final VoidCallback? onDetail;
  final VoidCallback? onEdit;

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('MM/dd');

    return AdCardGridShell(
      assetPath: ad.thumbnailAssetPath,
      networkUrl: ad.thumbnailUrl,
      onTap: onTap,
      thumbnailOverlays: [
        Positioned(
          top: 6,
          right: 6,
          child: _statusBadge(ad),
        ),
        if (ad.isOwnAd)
          const Positioned(
            top: 6,
            left: 6,
            child: AdCardBadge(label: '自社', color: AppColors.primary),
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
              labels: const ['開始', '終了', '配信'],
              values: [
                dateFormat.format(ad.startDate),
                dateFormat.format(ad.endDate),
                '${ad.distributorCount}',
              ],
            ),
          ],
        ),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextButton(
              onPressed: onDetail,
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: const Text('詳細', style: TextStyle(fontSize: 12)),
            ),
            TextButton(
              onPressed: onEdit,
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: const Text('編集', style: TextStyle(fontSize: 12)),
            ),
          ],
        ),
      ],
    );
  }

  Widget _statusBadge(Ad ad) {
    late final String label;
    late final Color color;
    if (ad.isEnded) {
      label = '終了';
      color = AppColors.ended;
    } else if (ad.isScheduled) {
      label = '予定';
      color = AppColors.scheduled;
    } else {
      label = '配信中';
      color = AppColors.distributing;
    }

    return AdCardBadge(label: label, color: color);
  }
}
