import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../data/ad_repository.dart';
import '../../models/ad.dart';
import '../../models/ad_publication_status.dart';
import '../../providers/ad_list_provider.dart';
import '../../theme/app_theme.dart';
import '../../utils/csv_export.dart';
import '../../widgets/admin_shell.dart';
import '../../widgets/ideal/ideal_theme.dart';

class AdminAdsPage extends ConsumerWidget {
  const AdminAdsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ads = ref.watch(adminAdsProvider);
    final statusFilter = ref.watch(adminAdsStatusFilterProvider);

    return AdminShell(
      currentLocation: GoRouterState.of(context).matchedLocation,
      title: '広告一覧',
      showNavigation: false,
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1100),
          child: ListView(
            padding: const EdgeInsets.all(IdealSpacing.xl),
            children: [
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      decoration: const InputDecoration(
                        labelText: '検索（会社名・キャッチコピー）',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.search),
                      ),
                      onChanged: (value) => ref
                          .read(adminAdsSearchProvider.notifier)
                          .state = value,
                    ),
                  ),
                  const SizedBox(width: IdealSpacing.md),
                  OutlinedButton.icon(
                    onPressed: () async {
                      final csv = buildAdsCsv(ads);
                      await Clipboard.setData(ClipboardData(text: csv));
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('CSVをクリップボードにコピーしました'),
                          ),
                        );
                      }
                    },
                    icon: const Icon(Icons.download_outlined),
                    label: const Text('CSV'),
                  ),
                ],
              ),
              const SizedBox(height: IdealSpacing.md),
              Wrap(
                spacing: IdealSpacing.sm,
                children: [
                  FilterChip(
                    label: const Text('すべて'),
                    selected: statusFilter == null,
                    onSelected: (_) => ref
                        .read(adminAdsStatusFilterProvider.notifier)
                        .state = null,
                  ),
                  for (final status in AdPublicationStatus.values)
                    FilterChip(
                      label: Text(status.label),
                      selected: statusFilter == status,
                      onSelected: (_) => ref
                          .read(adminAdsStatusFilterProvider.notifier)
                          .state = status,
                    ),
                ],
              ),
              const SizedBox(height: IdealSpacing.lg),
              Text(
                '${ads.length} 件',
                style: Theme.of(context).textTheme.titleSmall,
              ),
              const SizedBox(height: IdealSpacing.sm),
              DecoratedBox(
                decoration: BoxDecoration(
                  color: AppColors.card,
                  borderRadius: BorderRadius.circular(IdealRadii.card),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Column(
                  children: [
                    const _TableHeader(),
                    for (final ad in ads) _AdTableRow(ad: ad),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TableHeader extends StatelessWidget {
  const _TableHeader();

  @override
  Widget build(BuildContext context) {
    final style = Theme.of(context).textTheme.labelMedium?.copyWith(
          fontWeight: FontWeight.bold,
        );
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: IdealSpacing.md,
        vertical: IdealSpacing.sm,
      ),
      child: Row(
        children: [
          Expanded(flex: 3, child: Text('会社名', style: style)),
          Expanded(flex: 2, child: Text('ステータス', style: style)),
          Expanded(child: Text('配信', style: style)),
          Expanded(child: Text('参照', style: style)),
          const SizedBox(width: 120, child: Text('操作')),
        ],
      ),
    );
  }
}

class _AdTableRow extends ConsumerWidget {
  const _AdTableRow({required this.ad});

  final Ad ad;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: IdealSpacing.md,
        vertical: IdealSpacing.xs,
      ),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  ad.companyName,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                Text(
                  ad.catchCopy,
                  style: Theme.of(context).textTheme.bodySmall,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(ad.publicationStatus.label),
          ),
          Expanded(
            child: Text(ad.isDistributing ? 'ON' : 'OFF'),
          ),
          Expanded(child: Text('${ad.viewCount}')),
          SizedBox(
            width: 120,
            child: Wrap(
              spacing: 4,
              children: [
                IconButton(
                  tooltip: '詳細',
                  icon: const Icon(Icons.open_in_new, size: 20),
                  onPressed: () =>
                      context.push('/ads/${ad.id}?from=advertiser'),
                ),
                if (ad.isDistributing)
                  IconButton(
                    tooltip: '緊急停止',
                    icon: Icon(Icons.stop_circle_outlined,
                        size: 20, color: Colors.red.shade700),
                    onPressed: () {
                      ref
                          .read(adRepositoryProvider.notifier)
                          .emergencyStop(ad.id);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('「${ad.companyName}」を緊急停止しました')),
                      );
                    },
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
