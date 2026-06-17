import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../mock_data/categories_mock.dart';
import '../providers/ad_list_provider.dart';
import 'selectable_chip.dart';

class CategoryChips extends ConsumerWidget {
  const CategoryChips({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selected = ref.watch(selectedCategoryProvider);

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          for (var i = 0; i < categories.length; i++) ...[
            if (i > 0) const SizedBox(width: 8),
            SelectableChip(
              label: categories[i].name,
              selected: selected == categories[i].name,
              onTap: () {
                ref.read(selectedCategoryProvider.notifier).state =
                    categories[i].name;
              },
            ),
          ],
        ],
      ),
    );
  }
}
