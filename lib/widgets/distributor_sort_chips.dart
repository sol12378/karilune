import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/ad_list_provider.dart';
import 'selectable_chip.dart';

class DistributorSortChips extends ConsumerWidget {
  const DistributorSortChips({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sortOrder = ref.watch(distributorSortOrderProvider);
    final filter = ref.watch(distributorDistributionFilterProvider);

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                '並び替え',
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: Colors.grey.shade700,
                    ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      SelectableChip(
                        label: '新着順',
                        selected: sortOrder == SortOrder.newest,
                        onTap: () => ref
                            .read(distributorSortOrderProvider.notifier)
                            .state = SortOrder.newest,
                      ),
                      const SizedBox(width: 8),
                      SelectableChip(
                        label: '終了間近',
                        selected: sortOrder == SortOrder.endingSoon,
                        onTap: () => ref
                            .read(distributorSortOrderProvider.notifier)
                            .state = SortOrder.endingSoon,
                      ),
                      const SizedBox(width: 8),
                      SelectableChip(
                        label: 'お勧め順',
                        selected: sortOrder == SortOrder.recommended,
                        onTap: () => ref
                            .read(distributorSortOrderProvider.notifier)
                            .state = SortOrder.recommended,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Text(
                'フィルタ',
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: Colors.grey.shade700,
                    ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      SelectableChip(
                        label: 'すべて',
                        selected: filter == DistributorDistributionFilter.all,
                        onTap: () => ref
                            .read(distributorDistributionFilterProvider.notifier)
                            .state = DistributorDistributionFilter.all,
                      ),
                      const SizedBox(width: 8),
                      SelectableChip(
                        label: '配信中のみ',
                        selected:
                            filter == DistributorDistributionFilter.distributing,
                        onTap: () => ref
                            .read(distributorDistributionFilterProvider.notifier)
                            .state = DistributorDistributionFilter.distributing,
                      ),
                      const SizedBox(width: 8),
                      SelectableChip(
                        label: '未配信のみ',
                        selected: filter ==
                            DistributorDistributionFilter.notDistributing,
                        onTap: () => ref
                            .read(distributorDistributionFilterProvider.notifier)
                            .state =
                            DistributorDistributionFilter.notDistributing,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
