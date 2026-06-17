import '../models/notification.dart';

List<AppNotification> notificationsForRole(String role) {
  final now = DateTime.now();
  switch (role) {
    case 'member':
      return [
        AppNotification(
          id: 'n-m-1',
          title: '新着広告のお知らせ',
          body: 'お住まいの地域に新しい飲食店の広告が配信されました。',
          createdAt: now.subtract(const Duration(hours: 2)),
        ),
        AppNotification(
          id: 'n-m-2',
          title: 'お気に入り広告の終了間近',
          body: '「名古屋焼肉 炎」の配信があと3日で終了します。',
          createdAt: now.subtract(const Duration(days: 1)),
          isRead: true,
        ),
        AppNotification(
          id: 'n-m-3',
          title: 'キャンペーンのご案内',
          body: '春のガス機器点検キャンペーン実施中です。',
          createdAt: now.subtract(const Duration(days: 3)),
          isRead: true,
        ),
      ];
    case 'distributor':
      return [
        AppNotification(
          id: 'n-d-1',
          title: '配信依頼が届きました',
          body: '「すぐ駆けつけ修理 24」から配信依頼通知が届いています。',
          createdAt: now.subtract(const Duration(hours: 1)),
        ),
        AppNotification(
          id: 'n-d-2',
          title: '新規広告が追加されました',
          body: 'カテゴリ「飲食店」に新しい広告が3件追加されました。',
          createdAt: now.subtract(const Duration(hours: 5)),
        ),
        AppNotification(
          id: 'n-d-3',
          title: '配信レポート',
          body: '先週の配信広告の参照数が更新されました。',
          createdAt: now.subtract(const Duration(days: 2)),
          isRead: true,
        ),
      ];
    default:
      return [
        AppNotification(
          id: 'n-a-1',
          title: '広告が配信開始されました',
          body: '「自社広告：春の安全点検」が5事業者で配信開始されました。',
          createdAt: now.subtract(const Duration(hours: 3)),
        ),
        AppNotification(
          id: 'n-a-2',
          title: '審査完了のお知らせ',
          body: '投稿いただいた広告の審査が完了しました。',
          createdAt: now.subtract(const Duration(days: 1)),
        ),
        AppNotification(
          id: 'n-a-3',
          title: '請求書のご案内',
          body: '今月の広告配信料金の請求書を発行しました。',
          createdAt: now.subtract(const Duration(days: 4)),
          isRead: true,
        ),
      ];
  }
}
