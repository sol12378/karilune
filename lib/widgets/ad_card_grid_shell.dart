import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import 'ad_thumbnail.dart';

const double kAdCardThumbnailHeight = 100;

/// グリッド広告カード共通の外枠（サムネイル + 可変ボディ）
class AdCardGridShell extends StatelessWidget {
  const AdCardGridShell({
    super.key,
    required this.assetPath,
    this.networkUrl,
    this.onTap,
    this.thumbnailOverlays = const [],
    required this.children,
  });

  final String assetPath;
  final String? networkUrl;
  final VoidCallback? onTap;
  final List<Widget> thumbnailOverlays;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                AdThumbnail(
                  assetPath: assetPath,
                  networkUrl: networkUrl,
                  width: double.infinity,
                  height: kAdCardThumbnailHeight,
                  borderRadius: 0,
                ),
                ...thumbnailOverlays,
              ],
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(10, 8, 10, 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: children,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class AdCardBadge extends StatelessWidget {
  const AdCardBadge({
    super.key,
    required this.label,
    required this.color,
  });

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        label,
        style: const TextStyle(color: Colors.white, fontSize: 10),
      ),
    );
  }
}

class AdCardTitleBlock extends StatelessWidget {
  const AdCardTitleBlock({
    super.key,
    required this.companyName,
    required this.catchCopy,
    this.catchCopyMaxLines = 2,
  });

  final String companyName;
  final String catchCopy;
  final int catchCopyMaxLines;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          companyName,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: Colors.grey.shade600,
              ),
        ),
        const SizedBox(height: 2),
        Text(
          catchCopy,
          maxLines: catchCopyMaxLines,
          overflow: TextOverflow.ellipsis,
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
        ),
      ],
    );
  }
}

class AdCardSummaryRow extends StatelessWidget {
  const AdCardSummaryRow({
    super.key,
    required this.labels,
    required this.values,
  });

  final List<String> labels;
  final List<String> values;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        children: [
          for (var i = 0; i < labels.length; i++) ...[
            if (i > 0) const SizedBox(width: 4),
            Expanded(
              child: Column(
                children: [
                  Text(
                    labels[i],
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: Colors.grey.shade600,
                          fontSize: 10,
                        ),
                  ),
                  Text(
                    values[i],
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          fontSize: 11,
                        ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
