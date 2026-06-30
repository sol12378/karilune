import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../models/ad.dart';
import '../../providers/ad_list_provider.dart';
import '../../theme/app_theme.dart';
import '../ideal/ideal_theme.dart';

class DistributorTodayTasks extends ConsumerWidget {
  const DistributorTodayTasks({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tasks = ref.watch(distributorTodayTasksProvider);
    if (tasks.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: AppColors.primary.withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(IdealRadii.card),
          border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(IdealSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                '今日やること',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
              ),
              const SizedBox(height: IdealSpacing.sm),
              if (tasks.newlyPublished.isNotEmpty)
                _TaskGroup(
                  label: '新着（未配信）',
                  ads: tasks.newlyPublished,
                ),
              if (tasks.endingSoon.isNotEmpty)
                _TaskGroup(
                  label: '終了間近',
                  ads: tasks.endingSoon,
                ),
              if (tasks.spotlightNotDistributed.isNotEmpty)
                _TaskGroup(
                  label: 'スポットライト未配信',
                  ads: tasks.spotlightNotDistributed,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TaskGroup extends StatelessWidget {
  const _TaskGroup({required this.label, required this.ads});

  final String label;
  final List<Ad> ads;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: IdealSpacing.sm),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
          const SizedBox(height: IdealSpacing.xs),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                for (final ad in ads)
                  Padding(
                    padding: const EdgeInsets.only(right: IdealSpacing.sm),
                    child: ActionChip(
                      label: Text(ad.companyName),
                      onPressed: () =>
                          context.push('/ads/${ad.id}?from=distributor'),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
