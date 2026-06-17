class ClubMember {
  const ClubMember({
    required this.id,
    required this.name,
    required this.role,
    required this.joinedAt,
  });

  final String id;
  final String name;
  final String role;
  final DateTime joinedAt;
}
