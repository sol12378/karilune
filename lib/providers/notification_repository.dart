import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../mock_data/notifications_mock.dart';
import '../models/notification.dart';

class NotificationRepository extends StateNotifier<List<AppNotification>> {
  NotificationRepository() : super(notificationsForRole('all'));

  void addNotification(AppNotification notification) {
    state = [notification, ...state];
  }

  void markRead(String id) {
    state = state
        .map(
          (item) => item.id == id ? item.copyWith(isRead: true) : item,
        )
        .toList();
  }
}

final notificationRepositoryProvider =
    StateNotifierProvider<NotificationRepository, List<AppNotification>>(
  (ref) => NotificationRepository(),
);

final roleNotificationsProvider =
    Provider.family<List<AppNotification>, String>((ref, role) {
  final all = ref.watch(notificationRepositoryProvider);
  final dynamicItems = all.where((n) => n.id.startsWith('dyn-')).toList();
  final staticItems = notificationsForRole(role);
  return [...dynamicItems, ...staticItems];
});
