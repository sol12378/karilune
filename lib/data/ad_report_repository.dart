import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'audit_log_repository.dart';

class AdReport {
  const AdReport({
    required this.id,
    required this.adId,
    required this.reason,
    required this.reportedAt,
  });

  final String id;
  final String adId;
  final String reason;
  final DateTime reportedAt;
}

class AdReportRepository extends StateNotifier<List<AdReport>> {
  AdReportRepository(this._ref) : super(const []);

  final Ref _ref;

  void reportAd({required String adId, required String reason}) {
    final report = AdReport(
      id: 'report-${DateTime.now().microsecondsSinceEpoch}',
      adId: adId,
      reason: reason,
      reportedAt: DateTime.now(),
    );
    state = [report, ...state];
    _ref.read(auditLogRepositoryProvider.notifier).log(
          actor: '会員',
          action: '通報',
          targetType: 'ad',
          targetId: adId,
          detail: reason,
        );
  }

  void clear() {
    state = const [];
  }
}

final adReportRepositoryProvider =
    StateNotifierProvider<AdReportRepository, List<AdReport>>(
  AdReportRepository.new,
);
