/// 3つの主要画面の UI 設計原則（仕様書 §3.2 準拠 + 会員デモ拡張）。
///
/// | 画面 | Shell | Layout | 注目/お勧め | カテゴリ | 実績 | カード |
/// |------|-------|--------|------------|---------|------|--------|
/// | 会員スマホ | AppShell | ConsumerFeedLayout | FeaturedAdsCarousel | フィルタバー | なし | FeedAdCard |
/// | 会員PC | AppShell | MemberHomeLayout + FeedAdCard 2列 | FeaturedAdsCarousel | Sidebar | なし | FeedAdCard |
/// | 配信 | OperatorShell | DistributorBrowseLayout | FeaturedAdsCarousel | Sidebar+地域 | あり | AdCardDistributorVisual |
/// | 投稿 | OperatorShell | AdvertiserDashboardLayout | なし | なし | StatsGrid | AdCardAdvertiser |
///
/// §3.2 ワイヤーフレームはオペレーター（配信/投稿）向け。
/// 会員画面 `/member/*` は仕様書に明示がなく、閲覧ブロックのみをデモ拡張として提供する。
library;

enum AppScreenRole {
  member,
  distributor,
  advertiser,
}

class ScreenRoleConfig {
  const ScreenRoleConfig._();

  static const memberRoutePrefix = '/member';
  static const distributorRoutePrefix = '/distributor';
  static const advertiserRoutePrefix = '/advertiser';

  static AppScreenRole roleFromLocation(String location) {
    if (location.startsWith(distributorRoutePrefix)) {
      return AppScreenRole.distributor;
    }
    if (location.startsWith(advertiserRoutePrefix)) {
      return AppScreenRole.advertiser;
    }
    return AppScreenRole.member;
  }
}

/// 仕様書（20260115）で未実装の画面カテゴリ。
class SpecOutOfScope {
  const SpecOutOfScope._();

  static const unimplemented = [
    '認証（§3.1 ログイン・登録・パスワード変更）',
    '決済',
    '設定（ノーマル/ダークモード等）',
  ];
}
