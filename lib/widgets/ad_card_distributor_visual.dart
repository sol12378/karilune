import 'package:flutter/material.dart';

import '../models/ad.dart';
import '../theme/app_theme.dart';
import 'ad_card_grid_shell.dart';
import 'ad_thumbnail.dart';

/// 配信判断画面向け：画像主体の広告カード（ワイヤーフレーム準拠）。
///
/// - サムネイルをカードの大部分に表示（タップで詳細へ）
/// - 下部に大きなステータスボタン（配信中 / 未配信）
class AdCardDistributorVisual extends StatelessWidget {
  const AdCardDistributorVisual({
    super.key,
    required this.ad,
    this.onTap,
    this.onToggleDistribute,
    this.showCaption = true,
  });

  final Ad ad;
  final VoidCallback? onTap;
  final VoidCallback? onToggleDistribute;
  final bool showCaption;

  @override
  Widget build(BuildContext context) {
    final distributing = ad.isDistributing;
    final canOpenDetail = onTap != null;

    return Card(
      margin: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: _DetailTapTarget(
              enabled: canOpenDetail,
              label: '広告の詳細を見る',
              onTap: onTap,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  SizedBox.expand(
                    child: AdThumbnail(
                      assetPath: ad.thumbnailAssetPath,
                      networkUrl: ad.thumbnailUrl,
                      width: double.infinity,
                      height: double.infinity,
                      borderRadius: 0,
                    ),
                  ),
                  if (ad.hasSpotlightOption)
                    const Positioned(
                      top: 8,
                      left: 8,
                      child: AdCardBadge(
                        label: 'お勧め',
                        color: AppColors.accent,
                      ),
                    ),
                  if (canOpenDetail)
                    Positioned(
                      left: 0,
                      right: 0,
                      bottom: 0,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              Colors.black.withValues(alpha: 0.5),
                            ],
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(10, 16, 10, 8),
                          child: Row(
                            children: [
                              Icon(
                                Icons.zoom_out_map,
                                size: 16,
                                color: Colors.white.withValues(alpha: 0.95),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                '詳細を見る',
                                style: Theme.of(context)
                                    .textTheme
                                    .labelMedium
                                    ?.copyWith(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w600,
                                    ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
          if (showCaption)
            _DetailTapTarget(
              enabled: canOpenDetail,
              label: '広告の詳細を見る',
              onTap: onTap,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(10, 8, 10, 4),
                child: Text(
                  ad.catchCopy,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        height: 1.35,
                        color: AppColors.primary,
                      ),
                ),
              ),
            ),
          Padding(
            padding: const EdgeInsets.fromLTRB(10, 4, 10, 10),
            child: SizedBox(
              height: 44,
              width: double.infinity,
              child: FilledButton(
                onPressed: onToggleDistribute,
                style: FilledButton.styleFrom(
                  backgroundColor: distributing
                      ? AppColors.distributing
                      : AppColors.notDistributing,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  textStyle: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                child: Text(distributing ? '配信中' : '未配信'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DetailTapTarget extends StatelessWidget {
  const _DetailTapTarget({
    required this.enabled,
    required this.label,
    required this.onTap,
    required this.child,
  });

  final bool enabled;
  final String label;
  final VoidCallback? onTap;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    if (!enabled) return child;

    return Semantics(
      button: true,
      label: label,
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: InkWell(
          onTap: onTap,
          child: child,
        ),
      ),
    );
  }
}
