import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../providers/ad_list_provider.dart';
import '../theme/app_theme.dart';
import 'ad_thumbnail.dart';

/// 横スクロールの注目広告バナー（旧実装）。
///
/// 会員向けは [FeaturedAdsCarousel] を使用すること。
@Deprecated('Use FeaturedAdsCarousel for member home')
class SpotlightBanner extends ConsumerWidget {
  const SpotlightBanner({
    super.key,
    this.linkFrom = 'member',
    this.useMemberAds = true,
  });

  final String linkFrom;
  final bool useMemberAds;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ads = useMemberAds
        ? ref.watch(spotlightAdsProvider)
        : ref.watch(distributorSpotlightAdsProvider);
    if (ads.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 6),
          child: Text(
            '注目の広告',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
          ),
        ),
        SizedBox(
          height: 120,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: ads.length,
            separatorBuilder: (_, __) => const SizedBox(width: 10),
            itemBuilder: (context, index) {
              final ad = ads[index];
              return RepaintBoundary(
                key: ValueKey(ad.id),
                child: GestureDetector(
                onTap: () => context.push('/ads/${ad.id}?from=$linkFrom'),
                child: SizedBox(
                  width: 220,
                  child: Card(
                    child: Row(
                      children: [
                        AdThumbnail(
                          assetPath: ad.thumbnailAssetPath,
                          width: 80,
                          height: double.infinity,
                          borderRadius: 0,
                        ),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.all(8),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  ad.companyName,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  ad.catchCopy,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: Theme.of(context).textTheme.bodySmall,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              );
            },
          ),
        ),
      ],
    );
  }
}
