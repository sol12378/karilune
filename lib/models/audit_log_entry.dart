class AuditLogEntry {
  const AuditLogEntry({
    required this.id,
    required this.timestamp,
    required this.actor,
    required this.action,
    required this.targetType,
    required this.targetId,
    this.detail,
  });

  final String id;
  final DateTime timestamp;
  final String actor;
  final String action;
  final String targetType;
  final String targetId;
  final String? detail;

  String get summary {
    final detailSuffix = detail == null || detail!.isEmpty ? '' : ' — $detail';
    return '$action: $targetType/$targetId$detailSuffix';
  }
}
