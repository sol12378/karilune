import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../mock_data/club_members_mock.dart';
import '../../providers/operator_stats_provider.dart';
import '../../theme/app_theme.dart';
import '../../widgets/app_shell.dart';
import '../../widgets/ideal/ideal_theme.dart';
import '../../widgets/operator/operator_mode.dart';
import '../../widgets/operator/operator_shell.dart';

class ClubTeamPage extends ConsumerWidget {
  const ClubTeamPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final location = GoRouterState.of(context).matchedLocation;
    final dateFormat = DateFormat('yyyy/MM/dd');
    final stats = ref.watch(distributorPerformanceProvider);

    return OperatorShell(
      currentLocation: location,
      mode: OperatorMode.distributor,
      navItems: distributorNavItems,
      child: ListView(
        padding: const EdgeInsets.all(IdealSpacing.lg),
        children: [
          DecoratedBox(
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(IdealRadii.card),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Padding(
              padding: const EdgeInsets.all(IdealSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'チーム実績（配信ホームと連動）',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                  ),
                  const SizedBox(height: IdealSpacing.md),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _TeamStat(label: '広告数', value: '${stats.adCount}'),
                      _TeamStat(
                        label: '配信者数',
                        value: '${stats.distributorCount}',
                      ),
                      _TeamStat(label: '参照数', value: '${stats.viewCount}'),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: IdealSpacing.lg),
          DecoratedBox(
            decoration: BoxDecoration(
              color: AppColors.card,
              borderRadius: BorderRadius.circular(IdealRadii.card),
              border: Border.all(color: Colors.grey.shade200),
              boxShadow: IdealShadows.card,
            ),
            child: ListTile(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(IdealRadii.card),
              ),
              leading: const CircleAvatar(child: Icon(Icons.group_add)),
              title: const Text('メンバーを招待'),
              subtitle: const Text('メールアドレスでチームメンバーを招待（モック）'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('招待メールを送信しました（モック）')),
                );
              },
            ),
          ),
          const SizedBox(height: IdealSpacing.lg),
          Text(
            'チームメンバー',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: IdealSpacing.sm),
          for (final member in clubMembers)
            Padding(
              padding: const EdgeInsets.only(bottom: IdealSpacing.sm),
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: AppColors.card,
                  borderRadius: BorderRadius.circular(IdealRadii.card),
                  border: Border.all(color: Colors.grey.shade200),
                  boxShadow: IdealShadows.card,
                ),
                child: ListTile(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(IdealRadii.card),
                  ),
                  leading: CircleAvatar(
                    child: Text(member.name.characters.first),
                  ),
                  title: Text(member.name),
                  subtitle: Text(
                    '${member.role} · 参加日 ${dateFormat.format(member.joinedAt)}',
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _TeamStat extends StatelessWidget {
  const _TeamStat({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
        ),
        Text(label, style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }
}
