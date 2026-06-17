import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/ad_list_provider.dart';
import 'selectable_chip.dart';

class SortChips extends ConsumerWidget {
  const SortChips({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selected = ref.watch(sortOrderProvider);

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
      child: Row(
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
                    selected: selected == SortOrder.newest,
                    onTap: () => ref.read(sortOrderProvider.notifier).state =
                        SortOrder.newest,
                  ),
                  const SizedBox(width: 8),
                  SelectableChip(
                    label: '終了間近',
                    selected: selected == SortOrder.endingSoon,
                    onTap: () => ref.read(sortOrderProvider.notifier).state =
                        SortOrder.endingSoon,
                  ),
                  const SizedBox(width: 8),
                  SelectableChip(
                    label: '人気順',
                    selected: selected == SortOrder.popular,
                    onTap: () => ref.read(sortOrderProvider.notifier).state =
                        SortOrder.popular,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
