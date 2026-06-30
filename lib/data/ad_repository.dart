import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../mock_data/demo_scenarios.dart';
import '../models/ad.dart';
import '../models/ad_publication_status.dart';
import '../models/notification.dart';
import '../providers/notification_repository.dart';
import 'audit_log_repository.dart';

class AdRepository extends StateNotifier<List<Ad>> {
  AdRepository({required Ref ref, DemoScenarioId scenario = DemoScenarioId.s1Default})
      : _ref = ref,
        super(adsForScenario(scenario));

  final Ref _ref;

  List<Ad> getAll() => state;

  Ad? findById(String id) {
    try {
      return state.firstWhere((ad) => ad.id == id);
    } catch (_) {
      return null;
    }
  }

  void upsert(Ad ad) {
    final index = state.indexWhere((item) => item.id == ad.id);
    if (index == -1) {
      state = [ad, ...state];
      return;
    }
    final updated = List<Ad>.from(state);
    updated[index] = ad;
    state = updated;
  }

  void toggleDistributing(String adId) {
    state = state
        .map(
          (ad) {
            if (ad.id != adId) return ad;
            final turningOn = !ad.isDistributing;
            return ad.copyWith(
              isDistributing: turningOn,
              wasDistributed: turningOn ? true : ad.wasDistributed,
              distributorCount: turningOn
                  ? ad.distributorCount + 1
                  : ad.distributorCount,
            );
          },
        )
        .toList();
    _ref.read(auditLogRepositoryProvider.notifier).log(
          actor: '配信者',
          action: '配信切替',
          targetType: 'ad',
          targetId: adId,
          detail: findById(adId)?.isDistributing == true ? 'ON' : 'OFF',
        );
  }

  void incrementViewCount(String adId) {
    state = state
        .map(
          (ad) => ad.id == adId
              ? ad.copyWith(viewCount: ad.viewCount + 1)
              : ad,
        )
        .toList();
  }

  void publishAfterPayment(Ad ad) {
    upsert(ad.copyWith(publicationStatus: AdPublicationStatus.published));
  }

  void approveReview(String adId) {
    final ad = findById(adId);
    if (ad == null || !ad.isPendingReview) return;
    upsert(
      ad.copyWith(
        publicationStatus: AdPublicationStatus.published,
        reviewedAt: DateTime.now(),
        reviewNote: null,
      ),
    );
    _ref.read(auditLogRepositoryProvider.notifier).log(
          actor: '運営',
          action: '審査承認',
          targetType: 'ad',
          targetId: adId,
          detail: ad.companyName,
        );
    _ref.read(notificationRepositoryProvider.notifier).addNotification(
          AppNotification(
            id: 'dyn-review-$adId-${DateTime.now().millisecondsSinceEpoch}',
            title: '新着広告が審査通過しました',
            body: '「${ad.companyName}」の配信を検討してください。',
            createdAt: DateTime.now(),
            adId: adId,
            targetRoute: '/ads/$adId?from=distributor',
          ),
        );
  }

  void rejectReview(String adId, String note) {
    final ad = findById(adId);
    if (ad == null || !ad.isPendingReview) return;
    upsert(
      ad.copyWith(
        publicationStatus: AdPublicationStatus.rejected,
        reviewNote: note,
        reviewedAt: DateTime.now(),
      ),
    );
    _ref.read(auditLogRepositoryProvider.notifier).log(
          actor: '運営',
          action: '審査却下',
          targetType: 'ad',
          targetId: adId,
          detail: note,
        );
  }

  void returnToDraft(String adId, String note) {
    final ad = findById(adId);
    if (ad == null || !ad.isPendingReview) return;
    upsert(
      ad.copyWith(
        publicationStatus: AdPublicationStatus.draft,
        reviewNote: note,
        reviewedAt: DateTime.now(),
      ),
    );
    _ref.read(auditLogRepositoryProvider.notifier).log(
          actor: '運営',
          action: '審査差戻し',
          targetType: 'ad',
          targetId: adId,
          detail: note,
        );
  }

  void resubmitForReview(String adId) {
    final ad = findById(adId);
    if (ad == null || (!ad.isDraft && !ad.isRejected)) return;
    upsert(
      ad.copyWith(
        publicationStatus: AdPublicationStatus.pendingReview,
        reviewNote: null,
        reviewedAt: null,
      ),
    );
    _ref.read(auditLogRepositoryProvider.notifier).log(
          actor: '作成元',
          action: '再申請',
          targetType: 'ad',
          targetId: adId,
          detail: ad.companyName,
        );
  }

  void emergencyStop(String adId) {
    final ad = findById(adId);
    if (ad == null) return;
    upsert(ad.copyWith(isDistributing: false));
    _ref.read(auditLogRepositoryProvider.notifier).log(
          actor: '運営',
          action: '緊急停止',
          targetType: 'ad',
          targetId: adId,
          detail: ad.companyName,
        );
  }

  void resetToScenario(DemoScenarioId scenario) {
    state = adsForScenario(scenario);
  }
}

final adRepositoryProvider =
    StateNotifierProvider<AdRepository, List<Ad>>((ref) {
  return AdRepository(ref: ref);
});
