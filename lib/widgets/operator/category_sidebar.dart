import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../mock_data/categories_mock.dart';
import '../../providers/ad_list_provider.dart';
import '../../theme/app_theme.dart';
import '../../theme/motion.dart';

class CategorySidebar extends ConsumerWidget {
  const CategorySidebar({
    super.key,
    this.showPrefectureFilter = false,
    this.shrinkWrap = false,
  });

  final bool showPrefectureFilter;
  final bool shrinkWrap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selected = ref.watch(selectedCategoryProvider);

    return Container(
      width: 200,
      decoration: BoxDecoration(
        color: AppColors.card,
        border: Border(
          right: BorderSide(color: Colors.grey.shade200),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Text(
              'カテゴリー',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
            ),
          ),
          if (shrinkWrap)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  for (final category in categories)
                    _CategoryTile(
                      label: category.name,
                      selected: selected == category.name,
                      onTap: () {
                        ref.read(selectedCategoryProvider.notifier).state =
                            category.name;
                      },
                    ),
                ],
              ),
            )
          else
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                children: [
                  for (final category in categories)
                    _CategoryTile(
                      label: category.name,
                      selected: selected == category.name,
                      onTap: () {
                        ref.read(selectedCategoryProvider.notifier).state =
                            category.name;
                      },
                    ),
                ],
              ),
            ),
          if (showPrefectureFilter)
            Padding(
              padding: const EdgeInsets.all(12),
              child: DropdownButtonFormField<String>(
                initialValue: ref.watch(selectedPrefectureProvider),
                decoration: const InputDecoration(
                  labelText: '地域で絞り込み',
                  border: OutlineInputBorder(),
                  isDense: true,
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                ),
                items: [
                  for (final prefecture in prefectures)
                    DropdownMenuItem(
                      value: prefecture,
                      child: Text(prefecture, style: const TextStyle(fontSize: 13)),
                    ),
                ],
                onChanged: (value) {
                  if (value != null) {
                    ref.read(selectedPrefectureProvider.notifier).state =
                        value;
                  }
                },
              ),
            ),
        ],
      ),
    );
  }
}

class _CategoryTile extends StatelessWidget {
  const _CategoryTile({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 2),
      child: AnimatedContainer(
        duration: AppMotion.normal,
        curve: AppMotion.curve,
        decoration: BoxDecoration(
          color: selected
              ? AppColors.primary.withValues(alpha: 0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: Border(
            left: BorderSide(
              color: selected ? AppColors.primary : Colors.transparent,
              width: 3,
            ),
          ),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(8),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: selected ? FontWeight.bold : FontWeight.normal,
                  color: selected ? AppColors.primary : Colors.grey.shade800,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// モバイル用: 横スクロールカテゴリチップ
class CategorySidebarCompact extends ConsumerWidget {
  const CategorySidebarCompact({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selected = ref.watch(selectedCategoryProvider);

    return SizedBox(
      height: 44,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        itemCount: categories.length,
        separatorBuilder: (_, __) => const SizedBox(width: 6),
        itemBuilder: (context, index) {
          final category = categories[index];
          final isSelected = selected == category.name;
          return FilterChip(
            label: Text(category.name, style: const TextStyle(fontSize: 12)),
            selected: isSelected,
            onSelected: (_) {
              ref.read(selectedCategoryProvider.notifier).state =
                  category.name;
            },
            visualDensity: VisualDensity.compact,
          );
        },
      ),
    );
  }
}
