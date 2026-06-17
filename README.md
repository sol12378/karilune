# カリルネ Flutter モック

カリルネ広告配信プラットフォームの画面モック（Flutter + Riverpod）。

## 機能

- **会員モード** `/member/home` — 配信中広告の閲覧・お気に入り（デフォルト起動先）
- 広告配信モード `/distributor/home` — カテゴリ絞り込み・配信ON/OFF
- 広告投稿モード `/advertiser/home` — 統計・タブ・新規作成
- 広告詳細（`from=member|distributor|advertiser` で表示分岐）
- 広告投稿（3ステップ・編集時は配信期間変更不可）

認証・DB は含みません。

## セットアップ

```bash
flutter pub get
flutter run -d chrome   # Web
flutter run             # 接続デバイス
```

## 技術スタック

- Flutter / Dart
- flutter_riverpod
- go_router
- freezed（イミュータブルモデル）
- google_fonts

## デモデータ

`lib/mock_data/ads_mock.dart` に20件のダミー広告。画像は `assets/images/` のプレースホルダーを使用（オフライン可）。
