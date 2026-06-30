# 配信詳細・広告編集・運営ダッシュボード 改修計画

## 背景と課題

| 課題 | 内容 |
|------|------|
| 配信者向け詳細 | 広告料金・オプションが表示され、配信判断に不要な情報が混在 |
| 広告編集 | 3ステップ（配信設定含む）で保存まで遠い、フォーム初期化の競合、サムネイル表示不良 |
| 運営ダッシュボード | 静的な活動ログのみで、運営者が状況を把握しづらい |

## Phase 1: 配信者向け詳細の整理（実装済み）

**対象:** [`lib/screens/ad_detail/ad_detail_page.dart`](../lib/screens/ad_detail/ad_detail_page.dart)

`from=distributor` のとき:

- **非表示:** 配信情報内の「広告料金」、「オプション」カード全体
- **表示維持:** 配信開始/終了/日数/カテゴリー、投稿者情報、下部の配信ボタン

作成元（`from=advertiser`）では料金・オプションを引き続き表示。

## Phase 2: 広告編集の修正（実装済み）

**対象:**

- [`lib/screens/ad_post/ad_post_page.dart`](../lib/screens/ad_post/ad_post_page.dart)
- [`lib/app_router.dart`](../lib/app_router.dart) `_AdPostRouteWrapper`
- [`lib/providers/ad_form_provider.dart`](../lib/providers/ad_form_provider.dart)

### 変更内容

| 項目 | 変更 |
|------|------|
| 編集ステップ | **素材 → 内容** の2ステップのみ（配信設定・決済は新規投稿のみ） |
| 保存タイミング | 内容ステップで「保存する」 |
| フォーム同期 | 編集ルートで `editingAdId` が揃うまでローディング表示 |
| ドロップダウン | `initialValue` → `value` で Riverpod 状態と同期 |
| サムネイル | `AdThumbnail` 統一（エラー時フォールバック） |
| 保存時 | 既存広告の投稿者情報・配信状態を `existing` から引き継ぎ |

### 編集フロー（改修後）

```mermaid
flowchart LR
  A[素材: サムネ選択] --> B[内容: 文言・カテゴリ]
  B --> C[保存 → advertiser/home]
```

## Phase 3: 運営ダッシュボード作り込み（実装済み）

**対象:**

- [`lib/screens/admin/admin_dashboard_page.dart`](../lib/screens/admin/admin_dashboard_page.dart)
- [`lib/providers/ad_list_provider.dart`](../lib/providers/ad_list_provider.dart) `adminDashboardStatsProvider`

### 構成

```
運営ダッシュボード
├── プラットフォーム概要（4 KPI）
│   ├── 登録広告数
│   ├── 配信中
│   ├── 会員表示中
│   └── 参照数合計
├── 要対応アラート（審査待ち・下書き）
├── 管理メニュー（3カード）
├── デモシナリオ切替
├── 直近の活動（mock 集計）
└── 審査待ち一覧（最大5件）
```

### データソース

すべて `AdRepository` + 既存 Provider から算出（本番 API なし）。

## Phase 4: PLATFORM_RESEARCH 準拠拡張（実装済み）

| 優先度 | 内容 | 実装 |
|--------|------|------|
| P0 | 審査待ち広告の承認/却下/差戻し UI | `AdminReviewQueue` + `AdRepository` 審査 API |
| P0 | 運営コントロールタワー拡張 | 要対応キュー（審査・通報・配信0）+ KPI 6 |
| P0 | 運営向け広告一覧・検索 | `/admin/ads` |
| P1 | 監査ログ | `AuditLogRepository` + ダッシュボード表示 |
| P1 | 配信者「今日やること」 | `DistributorTodayTasks` |
| P1 | 請求イベント設計プレビュー | `BillingEvent` mock + 折りたたみ表示 |
| P2 | 会員通報・掲載理由 | `ad_report_dialog` + 詳細/FeedAdCard |
| P2 | 作成元却下/終了セクション・再申請 | `home_advertiser_page` + `reviewNote` |
| P2 | 編集時プレビュー（`FeedAdCard`） | `ad_post_page` 内容ステップ |
| P2 | 軽量 CSV エクスポート | `csv_export.dart`（クリップボード） |

## デモ確認手順

1. **配信詳細:** 配信者ホーム → 広告詳細 → 料金・オプションがないこと
2. **広告編集:** 作成元ホーム → 編集 → 2ステップで保存できること
3. **運営:** `/admin/dashboard` → 審査操作・要対応・監査ログ・CSVを確認
4. **運営一覧:** `/admin/ads` → 検索・フィルタ・緊急停止
5. **配信者:** ホーム上部「今日やること」帯を確認
6. **会員:** 詳細の掲載理由・通報 → 運営要対応件数増加を確認
7. **作成元:** 却下理由・再申請 → 審査待ちに戻ること

## スコープ外

- 本番決済・審査ワークフローのバックエンド連携
- 運営者ロールの独立認証
