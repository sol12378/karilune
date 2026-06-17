import '../models/club_member.dart';

final clubMembers = <ClubMember>[
  ClubMember(
    id: 'cm-1',
    name: '山田 太郎',
    role: '管理者',
    joinedAt: DateTime(2024, 4, 1),
  ),
  ClubMember(
    id: 'cm-2',
    name: '佐藤 花子',
    role: '配信担当',
    joinedAt: DateTime(2024, 6, 15),
  ),
  ClubMember(
    id: 'cm-3',
    name: '鈴木 一郎',
    role: '閲覧のみ',
    joinedAt: DateTime(2025, 1, 10),
  ),
];
