import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/audit_log_entry.dart';

class AuditLogRepository extends StateNotifier<List<AuditLogEntry>> {
  AuditLogRepository() : super(const []);

  void log({
    required String actor,
    required String action,
    required String targetType,
    required String targetId,
    String? detail,
  }) {
    final entry = AuditLogEntry(
      id: 'audit-${DateTime.now().microsecondsSinceEpoch}',
      timestamp: DateTime.now(),
      actor: actor,
      action: action,
      targetType: targetType,
      targetId: targetId,
      detail: detail,
    );
    state = [entry, ...state];
  }

  void clear() {
    state = const [];
  }
}

final auditLogRepositoryProvider =
    StateNotifierProvider<AuditLogRepository, List<AuditLogEntry>>(
  (ref) => AuditLogRepository(),
);
