import 'package:flutter/material.dart';

import '../models/ad.dart';
import '../theme/app_theme.dart';
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
    this.onResubmit,
  });

  final Ad ad;
  final AdCardAdvertiserVariant variant;
  final VoidCallback? onTap;
  final VoidCallback? onDetail;
  final VoidCallback? onEdit;
  final VoidCallback? onResubmit;

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
            if (ad.reviewNote != null && ad.reviewNote!.isNotEmpty) ...[
              Text(
                '差戻し・却下理由: ${ad.reviewNote}',
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.red.shade700,
                  height: 1.3,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 6),
            ],
            _AdvertiserMiniStats(ad: ad, isHistory: isHistory),
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
        else if ((ad.isRejected || ad.isDraft) && onResubmit != null)
          Align(
            alignment: Alignment.centerRight,
            child: Wrap(
              spacing: 4,
              children: [
                if (onEdit != null)
                  TextButton(
                    onPressed: onEdit,
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: const Text('編集', style: TextStyle(fontSize: 12)),
                  ),
                TextButton(
                  onPressed: onResubmit,
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: const Text('再申請', style: TextStyle(fontSize: 12)),
                ),
              ],
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

class _AdvertiserMiniStats extends StatelessWidget {
  const _AdvertiserMiniStats({
    required this.ad,
    required this.isHistory,
  });

  final Ad ad;
  final bool isHistory;

  @override
  Widget build(BuildContext context) {
    final leadCount = (ad.viewCount * 0.05).round();
    final remainingDays = isHistory
        ? '-'
        : '${ad.endDate.difference(DateTime.now()).inDays.clamp(0, 999)}';

    const labels = ['配信者', '参照', 'リード', '残り'];
    final values = [
      '${ad.distributorCount}',
      '${ad.viewCount}',
      '$leadCount',
      remainingDays,
    ];

    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
        child: Row(
          children: List.generate(labels.length, (index) {
            return Expanded(
              child: Column(
                children: [
                  Text(
                    values[index],
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    labels[index],
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: Colors.grey.shade600,
                        ),
                  ),
                ],
              ),
            );
          }),
        ),
      ),
    );
  }
}
