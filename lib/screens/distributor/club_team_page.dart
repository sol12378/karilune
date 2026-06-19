import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../mock_data/club_members_mock.dart';
import '../../widgets/app_shell.dart';
import '../../widgets/operator/operator_mode.dart';
import '../../widgets/operator/operator_shell.dart';

class ClubTeamPage extends StatelessWidget {
  const ClubTeamPage({super.key});

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).matchedLocation;
    final dateFormat = DateFormat('yyyy/MM/dd');

    return OperatorShell(
      currentLocation: location,
      mode: OperatorMode.distributor,
      navItems: distributorNavItems,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: ListTile(
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
          const SizedBox(height: 16),
          Text(
            'チームメンバー',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 8),
          for (final member in clubMembers)
            Card(
              child: ListTile(
                leading: CircleAvatar(
                  child: Text(member.name.characters.first),
                ),
                title: Text(member.name),
                subtitle: Text(
                  '${member.role} · 参加日 ${dateFormat.format(member.joinedAt)}',
                ),
              ),
            ),
        ],
      ),
    );
  }
}
