import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../models/ad.dart';
import '../../../theme/app_theme.dart';
import '../../ad_thumbnail.dart';
import '../ideal_theme.dart';

/// お気に入り画面用のコンパクトカード（HTML `.fav-card` 相当）。
class FavoriteAdCard extends StatelessWidget {
  const FavoriteAdCard({
    super.key,
    required this.ad,
    this.onTap,
  });

  final Ad ad;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap ?? () => context.push('/ads/${ad.id}?from=member'),
      borderRadius: BorderRadius.circular(IdealRadii.card),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(IdealRadii.card),
          border: Border.all(color: Colors.grey.shade200),
          boxShadow: IdealShadows.card,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AspectRatio(
              aspectRatio: 1,
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(IdealRadii.card),
                ),
                child: AdThumbnail(
                  assetPath: ad.thumbnailAssetPath,
                  networkUrl: ad.thumbnailUrl,
                  width: double.infinity,
                  height: double.infinity,
                  borderRadius: 0,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10),
              child: Text(
                ad.catchCopy,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      height: 1.35,
                    ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
