import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../providers/ad_list_provider.dart';
import '../../theme/app_theme.dart';
import '../ad_thumbnail.dart';

class RecommendedCarousel extends ConsumerWidget {
  const RecommendedCarousel({
    super.key,
    this.linkFrom = 'distributor',
  });

  final String linkFrom;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ads = ref.watch(distributorSpotlightAdsProvider);
    if (ads.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
          child: Text(
            'お勧めの広告',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
          ),
        ),
        SizedBox(
          height: 140,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: ads.length,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              final ad = ads[index];
              return RepaintBoundary(
                key: ValueKey(ad.id),
                child: GestureDetector(
                  onTap: () =>
                      context.push('/ads/${ad.id}?from=$linkFrom'),
                  child: SizedBox(
                    width: 100,
                    child: Column(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: AdThumbnail(
                            assetPath: ad.thumbnailAssetPath,
                            networkUrl: ad.thumbnailUrl,
                            width: 100,
                            height: 100,
                            borderRadius: 0,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          ad.companyName,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 4),
      ],
    );
  }
}
