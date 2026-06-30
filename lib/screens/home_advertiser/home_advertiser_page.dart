import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../data/ad_repository.dart';
import '../../models/ad.dart';
import '../../providers/ad_list_provider.dart';
import '../../theme/breakpoints.dart';
import '../../widgets/ad_card_advertiser.dart';
import '../../widgets/ad_grid.dart';
import '../../widgets/ad_grid_skeleton.dart';
import '../../widgets/app_shell.dart';
import '../../widgets/common/section_header.dart';
import '../../widgets/demo_async_wrapper.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/ideal/advertiser/advertiser_dashboard_layout.dart';
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
          AdvertiserDashboardLayout(
            buildAdsSection: (width) => DemoAsyncWrapper(
              cacheKey: 'advertiser-home-grid',
              loading: AdGridSkeleton(
                crossAxisCount: width >= Breakpoints.desktop ? 3 : 2,
              ),
              builder: () => AdvertiserAdsGrid(width: width),
            ),
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

  void _resubmit(BuildContext context, WidgetRef ref, Ad ad) {
    ref.read(adRepositoryProvider.notifier).resubmitForReview(ad.id);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('「${ad.companyName}」を再申請しました')),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final split = ref.watch(advertiserAdsSplitProvider);
    final hasAny = split.drafts.isNotEmpty ||
        split.pending.isNotEmpty ||
        split.active.isNotEmpty ||
        split.rejected.isNotEmpty ||
        split.ended.isNotEmpty;

    if (!hasAny) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 48),
        child: EmptyState(
          icon: Icons.campaign_outlined,
          title: '広告はまだありません',
          description: '右下のボタンから新規広告を作成できます。',
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (split.active.isNotEmpty) ...[
          const SectionHeader(
            title: '配信中',
            subtitle: 'ガス会社等の配信者が会員へ届けている広告',
          ),
          _sectionGrid(context, ref, split.active),
          const SizedBox(height: 16),
        ],
        if (split.pending.isNotEmpty || split.drafts.isNotEmpty) ...[
          const SectionHeader(
            title: '審査中・下書き',
            subtitle: '公開前の広告を管理',
          ),
          if (split.pending.isNotEmpty) ...[
            _sectionGrid(context, ref, split.pending),
            const SizedBox(height: 8),
          ],
          if (split.drafts.isNotEmpty)
            _sectionGrid(context, ref, split.drafts),
          const SizedBox(height: 16),
        ],
        if (split.rejected.isNotEmpty) ...[
          const SectionHeader(
            title: '却下',
            subtitle: '理由を確認のうえ編集・再申請できます',
          ),
          _sectionGrid(context, ref, split.rejected),
          const SizedBox(height: 16),
        ],
        if (split.ended.isNotEmpty) ...[
          const SectionHeader(
            title: '終了',
            subtitle: '配信期間が終了した広告',
          ),
          _endedGrid(context, split.ended),
        ],
      ],
    );
  }

  Widget _sectionGrid(BuildContext context, WidgetRef ref, List<Ad> ads) {
    return AdGridView.builder(
      width: width,
      shrinkWrap: true,
      padding: const EdgeInsets.only(bottom: 8),
      itemCount: ads.length,
      itemBuilder: (context, index) {
        final ad = ads[index];
        return RepaintBoundary(
          key: ValueKey(ad.id),
          child: AdCardAdvertiser(
            ad: ad,
            onTap: () => context.push('/ads/${ad.id}?from=advertiser'),
            onEdit: () => context.push('/advertiser/ads/${ad.id}/edit'),
            onResubmit: (ad.isRejected || ad.isDraft)
                ? () => _resubmit(context, ref, ad)
                : null,
          ),
        );
      },
    );
  }

  Widget _endedGrid(BuildContext context, List<Ad> ads) {
    return AdGridView.builder(
      width: width,
      shrinkWrap: true,
      padding: const EdgeInsets.only(bottom: 8),
      itemCount: ads.length,
      itemBuilder: (context, index) {
        final ad = ads[index];
        return RepaintBoundary(
          key: ValueKey(ad.id),
          child: AdCardAdvertiser(
            ad: ad,
            variant: AdCardAdvertiserVariant.history,
            onTap: () => context.push('/ads/${ad.id}?from=advertiser'),
            onDetail: () => context.push('/ads/${ad.id}?from=advertiser'),
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
