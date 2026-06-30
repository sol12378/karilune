import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../models/ad.dart';
import '../../providers/ad_list_provider.dart';
import '../../theme/app_theme.dart';
import '../ad_card_distributor_visual.dart';
import '../ad_card_grid_shell.dart';

/// かつて配信した制作元の新作・再配信候補を横スクロールで表示。
class PastAdvertiserPickupCarousel extends ConsumerWidget {
  const PastAdvertiserPickupCarousel({
    super.key,
    this.onToggleDistribute,
  });

  final void Function(Ad ad)? onToggleDistribute;

  static const double _cardWidth = 220;
  static const double _cardHeight = 380;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ads = ref.watch(distributorPastAdvertiserPickupProvider);
    if (ads.isEmpty) return const SizedBox.shrink();

    final displayAds = ads.take(8).toList();

    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 0, 0, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 8, 16, 4),
            child: _PickupSectionTitle(),
          ),
          SizedBox(
            height: _cardHeight + 16,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
              itemCount: displayAds.length,
              separatorBuilder: (_, __) => const SizedBox(width: 16),
              itemBuilder: (context, index) {
                final ad = displayAds[index];
                return SizedBox(
                  width: _cardWidth,
                  height: _cardHeight,
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      AdCardDistributorVisual(
                        ad: ad,
                        showCaption: true,
                        onTap: () =>
                            context.push('/ads/${ad.id}?from=distributor'),
                        onToggleDistribute: onToggleDistribute == null
                            ? null
                            : () => onToggleDistribute!(ad),
                      ),
                      Positioned(
                        top: 8,
                        left: 8,
                        child: AdCardBadge(
                          label: '制作元',
                          color: AppColors.primary.withValues(alpha: 0.92),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _PickupSectionTitle extends StatelessWidget {
  const _PickupSectionTitle();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'かつて配信した制作元の広告',
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
        ),
        const SizedBox(height: 4),
        Text(
          '過去に配信実績のある広告主の新作。画像で比較して配信を決められます',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.grey.shade600,
              ),
        ),
      ],
    );
  }
}
