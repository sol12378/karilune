import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../data/ad_repository.dart';
import '../../models/ad.dart';
import '../../providers/ad_list_provider.dart';
import '../../providers/operator_stats_provider.dart';
import '../../theme/breakpoints.dart';
import '../../widgets/ad_card_distributor.dart';
import '../../widgets/ad_grid.dart';
import '../../widgets/ad_grid_skeleton.dart';
import '../../widgets/app_shell.dart';
import '../../widgets/common/section_header.dart';
import '../../widgets/demo_async_wrapper.dart';
import '../../widgets/distributor_sort_chips.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/member_filter_bar.dart';
import '../../widgets/operator/operator_home_layout.dart';
import '../../widgets/operator/operator_mode.dart';
import '../../widgets/operator/operator_shell.dart';

Future<void> confirmToggleDistributing(
  BuildContext context,
  WidgetRef ref,
  Ad ad,
) async {
  final isStop = ad.isDistributing;
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(isStop ? '配信停止の確認' : '配信開始の確認'),
      content: Text(
        isStop
            ? '「${ad.companyName}」の配信を停止しますか？'
            : '「${ad.companyName}」を配信しますか？',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text('キャンセル'),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(context, true),
          child: Text(isStop ? '停止する' : '配信する'),
        ),
      ],
    ),
  );
  if (confirmed == true) {
    ref.read(adRepositoryProvider.notifier).toggleDistributing(ad.id);
  }
}

class HomeDistributorPage extends ConsumerWidget {
  const HomeDistributorPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final location = GoRouterState.of(context).matchedLocation;

    return OperatorShell(
      currentLocation: location,
      mode: OperatorMode.distributor,
      navItems: distributorNavItems,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final showFilterBar = constraints.maxWidth < Breakpoints.mobile;

          return Stack(
            children: [
              OperatorHomeLayout(
                showRecommended: false,
                showPrefectureFilter: true,
                statsProvider: distributorPerformanceProvider,
                mainHeader: const Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    SectionHeader(
                      title: '配信候補の広告',
                      subtitle: '並び替え・フィルタで探して配信ON',
                    ),
                    DistributorSortChips(),
                  ],
                ),
                buildMain: (width) => DemoAsyncWrapper(
                  cacheKey: 'distributor-home-grid',
                  loading: AdGridSkeleton(
                    crossAxisCount: width >= Breakpoints.desktop ? 3 : 2,
                  ),
                  builder: () => DistributorAdsGrid(
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
      ),
    );
  }
}

class DistributorAdsGrid extends ConsumerWidget {
  const DistributorAdsGrid({
    super.key,
    required this.width,
    required this.bottomPadding,
  });

  final double width;
  final double bottomPadding;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final split = ref.watch(distributorAdsSplitProvider);

    if (split.all.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 48),
        child: EmptyState(
          icon: Icons.search_off_outlined,
          title: '該当する広告はありません',
          description: 'カテゴリや地域の条件を変更してみてください。',
        ),
      );
    }

    return Padding(
      padding: EdgeInsets.fromLTRB(16, 0, 16, bottomPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (split.ownDistributing.isNotEmpty) ...[
            const SectionHeader(
              title: '配信中の自社広告',
              subtitle: '現在会員へ配信中の自社分',
            ),
            _buildGrid(context, ref, split.ownDistributing),
            const SizedBox(height: 16),
          ],
          if (split.candidates.isNotEmpty) ...[
            if (split.ownDistributing.isNotEmpty)
              const SectionHeader(
                title: '配信候補・お勧め',
                subtitle: '未配信の広告を選んで配信開始',
              ),
            _buildGrid(context, ref, split.candidates),
          ],
        ],
      ),
    );
  }

  Widget _buildGrid(BuildContext context, WidgetRef ref, List<Ad> ads) {
    return AdGridView.builder(
      width: width,
      shrinkWrap: true,
      padding: const EdgeInsets.only(bottom: 8),
      itemCount: ads.length,
      itemBuilder: (context, index) {
        final ad = ads[index];
        return RepaintBoundary(
          key: ValueKey(ad.id),
          child: AdCardDistributor(
            ad: ad,
            onTap: () => context.push(
              '/ads/${ad.id}?from=distributor',
            ),
            onToggleDistribute: () =>
                confirmToggleDistributing(context, ref, ad),
          ),
        );
      },
    );
  }
}
