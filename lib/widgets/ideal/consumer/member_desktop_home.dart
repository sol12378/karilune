import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../providers/ad_list_provider.dart';
import '../../../theme/breakpoints.dart';
import '../../demo_async_wrapper.dart';
import '../../empty_state.dart';
import '../../member/member_home_layout.dart';
import '../../member_filter_bar.dart';
import '../ideal_theme.dart';
import 'feed_ad_card.dart';

/// PC向け会員ホーム：カテゴリサイドバー + FeedAdCard 2列グリッド。
class MemberDesktopHome extends ConsumerWidget {
  const MemberDesktopHome({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final showFilterBar = constraints.maxWidth < Breakpoints.mobile;

        return Stack(
          children: [
            MemberHomeLayout(
              buildMain: (width) => DemoAsyncWrapper(
                cacheKey: 'member-home-feed-grid',
                loading: const Padding(
                  padding: EdgeInsets.all(IdealSpacing.lg),
                  child: Center(child: CircularProgressIndicator()),
                ),
                builder: () => _MemberDesktopFeedGrid(
                  width: width,
                  bottomPadding: showFilterBar ? 80 : 24,
                ),
              ),
            ),
            if (showFilterBar)
              const Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: MemberFilterBar(),
              ),
          ],
        );
      },
    );
  }
}

class _MemberDesktopFeedGrid extends ConsumerWidget {
  const _MemberDesktopFeedGrid({
    required this.width,
    required this.bottomPadding,
  });

  final double width;
  final double bottomPadding;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ads = ref.watch(memberAdsProvider);

    if (ads.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 48),
        child: EmptyState(
          icon: Icons.campaign_outlined,
          title: '現在配信中の広告はありません',
          description: '配信者が広告を配信すると、ここに表示されます。',
        ),
      );
    }

    return Padding(
      padding: EdgeInsets.fromLTRB(
        IdealSpacing.lg,
        IdealSpacing.lg,
        IdealSpacing.lg,
        bottomPadding,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              children: [
                for (var i = 0; i < ads.length; i += 2)
                  Padding(
                    padding: const EdgeInsets.only(bottom: IdealSpacing.feedGap),
                    child: RepaintBoundary(
                      key: ValueKey(ads[i].id),
                      child: FeedAdCard(
                        ad: ads[i],
                        onTap: () =>
                            context.push('/ads/${ads[i].id}?from=member'),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: IdealSpacing.feedGap),
          Expanded(
            child: Column(
              children: [
                for (var i = 1; i < ads.length; i += 2)
                  Padding(
                    padding: const EdgeInsets.only(bottom: IdealSpacing.feedGap),
                    child: RepaintBoundary(
                      key: ValueKey(ads[i].id),
                      child: FeedAdCard(
                        ad: ads[i],
                        onTap: () =>
                            context.push('/ads/${ads[i].id}?from=member'),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
