import 'package:flutter/material.dart';

import '../models/ad.dart';
import '../theme/app_theme.dart';
import '../utils/date_formats.dart';
import 'ad_card_grid_shell.dart';

enum AdCardAdvertiserVariant { active, history }

class AdCardAdvertiser extends StatelessWidget {
  const AdCardAdvertiser({
    super.key,
    required this.ad,
    this.variant = AdCardAdvertiserVariant.active,
    this.onTap,
    this.onDetail,
    this.onEdit,
  });

  final Ad ad;
  final AdCardAdvertiserVariant variant;
  final VoidCallback? onTap;
  final VoidCallback? onDetail;
  final VoidCallback? onEdit;

  @override
  Widget build(BuildContext context) {
    final isHistory = variant == AdCardAdvertiserVariant.history;

    return AdCardGridShell(
      assetPath: ad.thumbnailAssetPath,
      networkUrl: ad.thumbnailUrl,
      onTap: onTap ?? onDetail,
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
              labels: isHistory
                  ? const ['開始', '終了', '配信日数', '参照数']
                  : const ['開始', '終了', '配信者数', '参照数'],
              values: [
                AppDateFormats.monthDay.format(ad.startDate),
                AppDateFormats.monthDay.format(ad.endDate),
                isHistory
                    ? '${ad.distributionDays}日'
                    : '${ad.distributorCount}',
                '${ad.viewCount}',
              ],
            ),
          ],
        ),
        if (isHistory)
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: onDetail,
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: const Text('詳細', style: TextStyle(fontSize: 12)),
            ),
          )
        else
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: onEdit,
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: const Text('編集', style: TextStyle(fontSize: 12)),
            ),
          ),
      ],
    );
  }

  Widget _statusBadge(Ad ad) {
    late final String label;
    late final Color color;
    if (ad.isDraft) {
      label = '下書き';
      color = Colors.grey;
    } else if (ad.isPendingReview) {
      label = '審査中';
      color = Colors.orange;
    } else if (ad.isRejected) {
      label = '却下';
      color = AppColors.ended;
    } else if (ad.isEnded) {
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
