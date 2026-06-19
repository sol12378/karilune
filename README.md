# カリルネ Flutter モック

カリルネ広告配信プラットフォームの画面モック（Flutter + Riverpod）。

## 画面ロール（3系統）

| ロール | ルート | Shell | 仕様書 |
|--------|--------|-------|--------|
| **会員（消費者）** | `/member/*` | AppShell | **§3.2 外のデモ拡張**（閲覧のみ） |
| **広告配信** | `/distributor/*` | OperatorShell | §3.2-(2) |
| **広告投稿** | `/advertiser/*` | OperatorShell | §3.2-(1) |

§3.2 ワイヤーフレーム（注目 + カテゴリ + メイン）は **オペレーター向け** です。ヘッダーの「投稿/配信モード切替」がその根拠です。会員画面は閲覧ブロックのみ同型レイアウト（`MemberHomeLayout`）で提供しています。

詳細は [docs/UI_ROLES.md](docs/UI_ROLES.md) を参照。

## 機能

- **会員** `/member/home` — 注目広告・カテゴリ絞り込み・お気に入り（デフォルト起動先）
- **配信** `/distributor/home` — お勧め・カテゴリ・地域・配信ON/OFF・実績パネル
- **投稿** `/advertiser/home` — 自社広告一覧・実績パネル・新規作成
- 広告詳細（`from=member|distributor|advertiser` で表示分岐）
- 広告投稿（素材→内容→配信設定→料金確認→モック決済→完了）
- **デモ用ログイン** `/login` — 会員・配信・投稿の3ロール切替（§3.1 モック）
- 管理ダッシュボード `/admin/dashboard` — 注目広告掲載管理

### 仕様書未実装（別フェーズ）

- 本番認証（登録・パスワード変更・OAuth）
- 実決済連携
- 設定（テーマ等）

本番DBは含みません。認証・決済はデモ用モックです。

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

## デモ用管理導線

会員画面からオペレーター画面へ入る導線は仕様外のため、次の2箇所に限定しています。

- 会員ホーム下部: 「広告管理（デモ用）」リンク
- 会員アカウント画面: 「広告管理ダッシュボード」リスト項目
