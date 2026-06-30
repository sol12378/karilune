import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../providers/ad_list_provider.dart';
import '../../empty_state.dart';
import '../ideal_theme.dart';
import 'distributor_banner.dart';
import 'feed_ad_card.dart';

/// 消費者ホーム：配信元バナー + 縦フィード（HTML consumer.html 相当）。
class ConsumerFeedLayout extends ConsumerWidget {
  const ConsumerFeedLayout({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ads = ref.watch(memberAdsProvider);

    if (ads.isEmpty) {
      return const CustomScrollView(
        slivers: [
          SliverToBoxAdapter(child: DistributorBanner()),
          SliverFillRemaining(
            hasScrollBody: false,
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 48),
              child: EmptyState(
                icon: Icons.campaign_outlined,
                title: '現在配信中の広告はありません',
                description: '配信者が広告を配信すると、ここに表示されます。',
              ),
            ),
          ),
        ],
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(
        0,
        0,
        0,
        IdealSpacing.bottomNavClearance,
      ),
      itemCount: ads.length + 1,
      itemBuilder: (context, index) {
        if (index == 0) {
          return const DistributorBanner();
        }

        final ad = ads[index - 1];
        return Padding(
          padding: const EdgeInsets.fromLTRB(
            IdealSpacing.feedPadding,
            IdealSpacing.feedGap,
            IdealSpacing.feedPadding,
            0,
          ),
          child: RepaintBoundary(
            key: ValueKey(ad.id),
            child: FeedAdCard(ad: ad),
          ),
        );
      },
    );
  }
}
