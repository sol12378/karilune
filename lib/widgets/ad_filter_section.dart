import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../mock_data/categories_mock.dart';
import '../providers/ad_list_provider.dart';
import 'category_chips.dart';
import 'sort_chips.dart';

class AdFilterSection extends ConsumerWidget {
  const AdFilterSection({
    super.key,
    this.showSort = true,
    this.showPrefectureDropdown = true,
  });

  final bool showSort;
  final bool showPrefectureDropdown;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (showSort) const SortChips(),
        const CategoryChips(),
        if (showPrefectureDropdown)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
            child: DropdownButtonFormField<String>(
              initialValue: ref.watch(selectedPrefectureProvider),
              decoration: const InputDecoration(
                labelText: '地域で絞り込み',
                border: OutlineInputBorder(),
                isDense: true,
              ),
              items: [
                for (final prefecture in prefectures)
                  DropdownMenuItem(
                    value: prefecture,
                    child: Text(prefecture),
                  ),
              ],
              onChanged: (value) {
                if (value != null) {
                  ref.read(selectedPrefectureProvider.notifier).state = value;
                }
              },
            ),
          ),
      ],
    );
  }
}
