# モックブラッシュアップ

デモ説明・UI統一のためのブラッシュアップ実装メモ。

## デモシナリオ

管理画面 `/admin/dashboard` の「デモシナリオ」から切り替え。

| ID | 名称 | 用途 |
|----|------|------|
| S1 | 通常運用 | 現行 mock（配信中広告あり） |
| S2 | 制作元ピックアップ | 過去配信制作元 + 新作未配信でピックアップ帯を強調 |
| S3 | 会員フィード空 | 全広告未配信 — 配信操作デモの導入 |
| S4 | 下書き・審査中混在 | 作成元ライフサイクルの説明 |

実装: `lib/mock_data/demo_scenarios.dart`, `lib/providers/demo_scenario_provider.dart`

## 推奨デモ手順（30秒）

1. **S1** で会員ホームを表示（配信中広告あり）
2. **配信者** `/distributor/home` で未配信広告を ON → SnackBar「会員フィードに表示」
3. **会員** ホームを再表示して反映を確認
4. 会員詳細で **お気に入り** / **電話**（mock SnackBar）

## UI 統一の要点

- 会員: スマホ・PC とも `FeedAdCard` 基準
- 配信者: ホーム・お気に入り・履歴とも `AdCardDistributorVisual` + `confirmToggleDistributing`
- 作成元: `AdCardAdvertiser` にミニ統計（配信者・参照・リード・残り日数）
- 会員通知: `NotificationTile` + 480px 中央フレーム

## スコープ外

- 効果レポート（チャート）
- 本番認証・実決済
- `url_launcher` 本番連携
