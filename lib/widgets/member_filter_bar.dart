import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../mock_data/categories_mock.dart';
import '../providers/ad_list_provider.dart';
import '../theme/app_theme.dart';

class MemberFilterBar extends ConsumerWidget {
  const MemberFilterBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final category = ref.watch(selectedCategoryProvider);
    final prefecture = ref.watch(selectedPrefectureProvider);

    return Material(
      elevation: 8,
      color: Colors.white,
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            children: [
              Expanded(
                child: _FilterButton(
                  icon: Icons.category_outlined,
                  label: category == 'すべて' ? 'カテゴリ' : category,
                  onTap: () => _showCategorySheet(context, ref),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _FilterButton(
                  icon: Icons.place_outlined,
                  label: prefecture == 'すべて' ? '地域' : prefecture,
                  onTap: () => _showPrefectureSheet(context, ref),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showCategorySheet(BuildContext context, WidgetRef ref) {
    showModalBottomSheet<void>(
      context: context,
      builder: (context) {
        return ListView(
          shrinkWrap: true,
          children: [
            for (final item in categories)
              ListTile(
                title: Text(item.name),
                trailing: ref.watch(selectedCategoryProvider) == item.name
                    ? const Icon(Icons.check, color: AppColors.primary)
                    : null,
                onTap: () {
                  ref.read(selectedCategoryProvider.notifier).state = item.name;
                  Navigator.pop(context);
                },
              ),
          ],
        );
      },
    );
  }

  void _showPrefectureSheet(BuildContext context, WidgetRef ref) {
    showModalBottomSheet<void>(
      context: context,
      builder: (context) {
        return ListView(
          shrinkWrap: true,
          children: [
            for (final item in prefectures)
              ListTile(
                title: Text(item),
                trailing: ref.watch(selectedPrefectureProvider) == item
                    ? const Icon(Icons.check, color: AppColors.primary)
                    : null,
                onTap: () {
                  ref.read(selectedPrefectureProvider.notifier).state = item;
                  Navigator.pop(context);
                },
              ),
          ],
        );
      },
    );
  }
}

class _FilterButton extends StatelessWidget {
  const _FilterButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: onTap,
      icon: Icon(icon, size: 18),
      label: Text(
        label,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(fontSize: 13),
      ),
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
      ),
    );
  }
}
