# UI ロール設計（仕様書 20260115 準拠）

## §3.2 ワイヤーフレームの解釈

添付ワイヤーフレーム「3.2 ホーム」のヘッダーには **広告投稿モード／広告配信モード切替** があります。  
これは **ガス事業者・広告主向けオペレーターアプリ** のホーム定義であり、会員（消費者）向け画面ではありません。

## 3画面の役割分担

| 要素 | 会員 `/member/*` | 配信 `/distributor/*` | 投稿 `/advertiser/*` |
|------|------------------|----------------------|---------------------|
| Shell | `AppShell` | `OperatorShell` | `OperatorShell` |
| Layout | `ConsumerFeedLayout` | `DistributorBrowseLayout` | `AdvertiserDashboardLayout` |
| 共通骨格 | `BrowseHomeLayout` | `BrowseHomeLayout` | `BrowseHomeLayout` |
| 注目/お勧め | `FeaturedAdsCarousel`（注目） | グリッド内「お勧め」バッジ | なし |
| カテゴリ | 左 Sidebar + 地域 | 左 Sidebar + 地域 | なし |
| 実績パネル | なし | あり | あり |
| カード | `FeedAdCard` | `AdCardDistributorVisual`（画像タップ→詳細） | `AdCardAdvertiser`（ミニ統計4列） |
| 主操作 | 閲覧・お気に入り | 配信する/停止 | 編集 |

## ファイル対応

```
lib/widgets/layout/browse_home_layout.dart   # 閲覧骨格（会員・配信で共有）
lib/widgets/member/member_home_layout.dart   # 会員ホーム
lib/widgets/operator/operator_home_layout.dart # オペレーターホーム
lib/widgets/layout/screen_roles.dart         # ロール定義・未実装一覧
```

## 会員画面について

機能仕様書の画面一覧には **会員向け独立ホーム** の定義がありません。  
機能仕様書の画面一覧には **会員向け独立ホーム** の定義がありません。  
本モックでは `/member/home` を **デモ拡張** として追加しています。

- **スマホ（幅 &lt; 900px）**: 縦フィード（`ConsumerFeedLayout`、最大幅 480px）
- **PC（幅 ≥ 900px）**: カテゴリサイドバー + `FeedAdCard` 2列グリッド（`MemberDesktopHome`）

## 二次画面（ブラッシュアップ後）

| 画面 | カード / レイアウト |
|------|---------------------|
| `/member/favorites` | `FavoriteAdCard` + `MemberContentFrame` |
| `/member/notifications` | `NotificationTile` + `MemberContentFrame` |
| `/distributor/favorites` | `AdCardDistributorVisual` |
| `/distributor/history` | `AdCardDistributorVisual` |
| `/distributor/club-team` | `IdealSpacing` / `IdealRadii` 適用 |

## デモシナリオ

管理ダッシュボード `/admin/dashboard` から S1〜S4 を切り替え可能。詳細は `docs/MOCK_BRUSHUP.md` を参照。

オペレーター要素（モード切替・配信ボタン・実績パネル）は会員画面に含めません。

## 配信判断 → 詳細遷移

配信者ホーム（`/distributor/home`）の画像主体カードでは、**画像・キャッチコピータップ**で `/ads/:id?from=distributor` へ遷移します。詳細画面の下部からも配信開始・停止が可能です。実装計画は `docs/FLUTTER_IDEAL_UI_PLAN.md` を参照してください。

## デモ用管理導線

本番ではガス事業者が別管理画面からオペレーターモードに入る想定です。  
モックでは次を提供します。

- `/login` — 3ロールのデモ用ログイン（会員・配信・投稿）
- アカウント画面 — ロール切替・ログアウト
- 配信/投稿アカウント — 管理ダッシュボード `/admin/dashboard`
- 注目広告掲載管理 `/admin/featured-placements`

## モック実装済み（デモ用）

- §3.1 認証 — 固定3ロールログイン・セッション永続化
- 決済 — 投稿フロー内のモック決済・完了画面

## 関連ドキュメント

- [PLATFORM_RESEARCH.md](./PLATFORM_RESEARCH.md) — 選考事例・統治型プラットフォーム調査
- [MOCK_BRUSHUP.md](./MOCK_BRUSHUP.md) — デモシナリオ・ブラッシュアップ
- [ADMIN_OPERATOR_PLAN.md](./ADMIN_OPERATOR_PLAN.md) — 運営・編集画面改修計画

## 未実装（本番・別フェーズ）

- 本番認証（登録・パスワード変更・OAuth）
- 実決済連携
- 設定
