import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../data/ad_repository.dart';
import '../../models/ad.dart';
import '../../providers/ad_list_provider.dart';
import '../../providers/operator_stats_provider.dart';
import '../../widgets/ad_card_distributor.dart';
import '../../widgets/ad_grid.dart';
import '../../widgets/app_shell.dart';
import '../../widgets/empty_state.dart';
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
      child: OperatorHomeLayout(
        showRecommended: true,
        showPrefectureFilter: true,
        statsProvider: distributorPerformanceProvider,
        buildMain: (width) => DistributorAdsGrid(width: width),
      ),
    );
  }
}

class DistributorAdsGrid extends ConsumerWidget {
  const DistributorAdsGrid({super.key, required this.width});

  final double width;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ads = ref.watch(filteredAdsProvider);

    if (ads.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 48),
        child: EmptyState(
          icon: Icons.search_off_outlined,
          title: '該当する広告はありません',
          description: 'カテゴリや地域の条件を変更してみてください。',
        ),
      );
    }

    return AdGridView.builder(
      width: width,
      shrinkWrap: true,
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
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
