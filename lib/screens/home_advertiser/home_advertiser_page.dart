import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../models/ad.dart';
import '../../providers/ad_list_provider.dart';
import '../../providers/operator_stats_provider.dart';
import '../../widgets/ad_card_advertiser.dart';
import '../../widgets/ad_grid.dart';
import '../../widgets/app_shell.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/operator/operator_home_layout.dart';
import '../../widgets/operator/operator_mode.dart';
import '../../widgets/operator/operator_shell.dart';

class HomeAdvertiserPage extends ConsumerWidget {
  const HomeAdvertiserPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final location = GoRouterState.of(context).matchedLocation;

    return OperatorShell(
      currentLocation: location,
      mode: OperatorMode.advertiser,
      navItems: advertiserNavItems,
      child: Stack(
        children: [
          OperatorHomeLayout(
            showRecommended: false,
            showCategorySidebar: false,
            statsProvider: advertiserPerformanceProvider,
            buildMain: (width) => AdvertiserAdsGrid(width: width),
          ),
          Positioned(
            right: 16,
            bottom: 16,
            child: FloatingActionButton.extended(
              onPressed: () => context.push('/advertiser/ads/new'),
              icon: const Icon(Icons.add),
              label: const Text('新規作成'),
            ),
          ),
        ],
      ),
    );
  }
}

class AdvertiserAdsGrid extends ConsumerWidget {
  const AdvertiserAdsGrid({super.key, required this.width});

  final double width;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ads = ref.watch(activeAdvertiserAdsProvider);

    if (ads.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 48),
        child: EmptyState(
          icon: Icons.campaign_outlined,
          title: '配信中・予定の広告はありません',
          description: '右下のボタンから新規広告を作成できます。',
        ),
      );
    }

    return AdGridView.builder(
      width: width,
      shrinkWrap: true,
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 88),
      itemCount: ads.length,
      itemBuilder: (context, index) {
        final ad = ads[index];
        return RepaintBoundary(
          key: ValueKey(ad.id),
          child: AdCardAdvertiser(
            ad: ad,
            onTap: () => context.push('/ads/${ad.id}?from=advertiser'),
            onEdit: () => context.push('/advertiser/ads/${ad.id}/edit'),
          ),
        );
      },
    );
  }
}

class AdvertiserAdGrid extends ConsumerWidget {
  const AdvertiserAdGrid({
    super.key,
    required this.ads,
    this.padding = const EdgeInsets.fromLTRB(16, 16, 16, 88),
  });

  final List<Ad> ads;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AdGridView.builder(
      padding: padding,
      shrinkWrap: true,
      itemCount: ads.length,
      itemBuilder: (context, index) {
        final ad = ads[index];
        return AdCardAdvertiser(
          ad: ad,
          onTap: () => context.push('/ads/${ad.id}?from=advertiser'),
          onEdit: () => context.push('/advertiser/ads/${ad.id}/edit'),
        );
      },
    );
  }
}
