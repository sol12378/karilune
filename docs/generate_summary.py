# -*- coding: utf-8 -*-
"""カリルネ Flutter モック 実装サマリ（A4 縦 1枚）
   ホスティング比較解説 PDF の意匠（ナビ帯ヘッダ / パステル構成図 /
   メリット・デメリット 2 カラム / 縞テーブル）を踏襲した方針確認資料。"""
import os
from reportlab.lib.pagesizes import A4
from reportlab.lib import colors
from reportlab.lib.units import mm
from reportlab.pdfgen import canvas
from reportlab.pdfbase import pdfmetrics
from reportlab.pdfbase.ttfonts import TTFont

FONT_DIR = os.path.join(os.path.dirname(os.path.abspath(__file__)), 'fonts')
pdfmetrics.registerFont(TTFont('JP',   os.path.join(FONT_DIR, 'NSJP-Regular.ttf')))
pdfmetrics.registerFont(TTFont('JPM',  os.path.join(FONT_DIR, 'NSJP-Medium.ttf')))
pdfmetrics.registerFont(TTFont('JPB',  os.path.join(FONT_DIR, 'NSJP-Bold.ttf')))
R, M, B = 'JP', 'JPM', 'JPB'

W, H = A4

# ── パレット（参考資料の配色に合わせる）────────────────────
NAVY    = colors.HexColor('#33424F')
NAVY_D  = colors.HexColor('#26323C')
INK     = colors.HexColor('#2B3640')
GRAY    = colors.HexColor('#5C6873')
GRAYL   = colors.HexColor('#8A95A0')
ORANGE  = colors.HexColor('#E8841A')
LINE    = colors.HexColor('#C9D2DB')
WHITE   = colors.white

# パステル box（fill, border, 濃色テキスト）
GREEN   = (colors.HexColor('#E7F3E6'), colors.HexColor('#6FAE55'), colors.HexColor('#3C7A2E'))
BLUE    = (colors.HexColor('#E3EDF9'), colors.HexColor('#5B9BD5'), colors.HexColor('#2E5E92'))
YELLOW  = (colors.HexColor('#FBF2D6'), colors.HexColor('#D7AE38'), colors.HexColor('#8A6A12'))
PURPLE  = (colors.HexColor('#ECE4F4'), colors.HexColor('#9A72BE'), colors.HexColor('#603A86'))
ORANGEB = (colors.HexColor('#FBE7D5'), colors.HexColor('#E0883E'), colors.HexColor('#9A551A'))
GRAYB   = (colors.HexColor('#ECEFF2'), colors.HexColor('#9AA7B4'), colors.HexColor('#4F5A64'))

MARGIN = 14 * mm
CW = W - 2 * MARGIN  # content width

c = canvas.Canvas(
    os.path.join(os.path.dirname(os.path.abspath(__file__)), 'carilune_summary.pdf'),
    pagesize=A4)


# ── 共通描画ヘルパ ─────────────────────────────────────
def fig_label(y, tag, title):
    """図ラベル（薄グレー帯 + ナビ小箱）"""
    h = 7 * mm
    c.setFillColor(colors.HexColor('#EDF0F3'))
    c.roundRect(MARGIN, y - h, CW, h, 2, fill=1, stroke=0)
    c.setFillColor(NAVY)
    c.roundRect(MARGIN + 2, y - h + 1.2, 13 * mm, h - 2.4, 2, fill=1, stroke=0)
    c.setFont(B, 8.5); c.setFillColor(WHITE)
    c.drawCentredString(MARGIN + 2 + 6.5 * mm, y - h + 2.3 * mm, tag)
    c.setFont(B, 9.5); c.setFillColor(INK)
    c.drawString(MARGIN + 18 * mm, y - h + 2.3 * mm, title)
    return y - h - 3 * mm


def sec_label(y, title):
    """セクション見出し（オレンジ下線）"""
    c.setFont(B, 10.5); c.setFillColor(INK)
    c.drawString(MARGIN, y - 4 * mm, title)
    c.setStrokeColor(ORANGE); c.setLineWidth(1.6)
    c.line(MARGIN, y - 5.6 * mm, MARGIN + CW, y - 5.6 * mm)
    return y - 9.5 * mm


def box(x, y, w, h, palette, title, sub=None, tf=B, ts=8, radius=2.5,
        title_dy=None):
    fill, border, txt = palette
    c.setFillColor(fill); c.setStrokeColor(border); c.setLineWidth(1)
    c.roundRect(x, y - h, w, h, radius, fill=1, stroke=1)
    c.setFillColor(txt)
    if sub:
        c.setFont(tf, ts)
        c.drawCentredString(x + w / 2, y - h / 2 + 0.7 * mm, title)
        c.setFont(R, 6.6); c.setFillColor(GRAY)
        c.drawCentredString(x + w / 2, y - h / 2 - 2.6 * mm, sub)
    else:
        c.setFont(tf, ts)
        dy = title_dy if title_dy is not None else (h / 2 - 1.2 * mm)
        c.drawCentredString(x + w / 2, y - dy, title)


def arrow_down(cx, y_top, y_bot, label=None, label_side='right'):
    c.setStrokeColor(GRAYL); c.setLineWidth(1.1)
    c.line(cx, y_top, cx, y_bot + 1.6 * mm)
    p = c.beginPath()
    p.moveTo(cx - 1.7 * mm, y_bot + 1.8 * mm)
    p.lineTo(cx + 1.7 * mm, y_bot + 1.8 * mm)
    p.lineTo(cx, y_bot - 0.4 * mm)
    p.close()
    c.setFillColor(GRAYL); c.drawPath(p, fill=1, stroke=0)
    if label:
        c.setFont(R, 6.8); c.setFillColor(GRAY)
        my = (y_top + y_bot) / 2
        if label_side == 'right':
            c.drawString(cx + 2.5 * mm, my - 1 * mm, label)
        else:
            c.drawRightString(cx - 2.5 * mm, my - 1 * mm, label)


# ════════════════════════════════════════════════════════
# ヘッダ帯
# ════════════════════════════════════════════════════════
BANDH = 25 * mm
c.setFillColor(NAVY); c.rect(0, H - BANDH, W, BANDH, fill=1, stroke=0)
c.setFillColor(ORANGE); c.rect(0, H - BANDH, W, 1.4 * mm, fill=1, stroke=0)

c.setFont(B, 16); c.setFillColor(WHITE)
title_a = 'カリルネ  Flutter モック'
c.drawString(MARGIN, H - 12 * mm, title_a)
sep_x = MARGIN + c.stringWidth(title_a, B, 16) + 3 * mm
c.setFillColor(colors.HexColor('#7F8FA0')); c.setFont(R, 16)
c.drawString(sep_x, H - 12 * mm, '│')
c.setFont(B, 16); c.setFillColor(WHITE)
c.drawString(sep_x + 4 * mm, H - 12 * mm, '実装方針サマリ')

c.setFont(R, 8.3); c.setFillColor(colors.HexColor('#C3D0DC'))
c.drawString(MARGIN, H - 18.4 * mm,
    'スポーツクラブを媒介に企業広告を配信するプラットフォーム。広告主・配信者・会員・管理者の 4 ロールに対応し、')
c.drawString(MARGIN, H - 22.4 * mm,
    'バックエンドなしのモックとして全画面・主要フローを実装済み。本資料は実装方針の確認用（上司向け）。')

y = H - BANDH - 4 * mm

# ════════════════════════════════════════════════════════
# 図A : アーキテクチャ構成（データフロー）
# ════════════════════════════════════════════════════════
y = fig_label(y, '図A', 'アーキテクチャ構成 ─ 状態管理を中心とした単方向データフロー')

cx = W / 2

# Row1: 利用者 4ロール chip
roles = [('会員', BLUE), ('配信者（クラブ）', GREEN), ('広告主', ORANGEB), ('管理者', PURPLE)]
chip_gap = 3 * mm
chip_w = (CW - chip_gap * 3) / 4
chip_h = 9 * mm
for i, (name, pal) in enumerate(roles):
    bx = MARGIN + i * (chip_w + chip_gap)
    fill, border, txt = pal
    c.setFillColor(fill); c.setStrokeColor(border); c.setLineWidth(1)
    c.roundRect(bx, y - chip_h, chip_w, chip_h, 2.5, fill=1, stroke=1)
    c.setFillColor(txt); c.setFont(B, 8.5)
    c.drawCentredString(bx + chip_w / 2, y - chip_h / 2 + 0.6 * mm, name)
    c.setFont(R, 6.3); c.setFillColor(GRAY)
    c.drawCentredString(bx + chip_w / 2, y - chip_h / 2 - 2.7 * mm, '利用者ロール')
y_chip_bot = y - chip_h

# arrow
y_router_top = y_chip_bot - 8.5 * mm
arrow_down(cx, y_chip_bot, y_router_top, '画面遷移（go_router）')

# Row2: go_router
gr_w = 150 * mm
gr_h = 11 * mm
gr_x = (W - gr_w) / 2
box(gr_x, y_router_top, gr_w, gr_h, BLUE,
    'go_router  ─  宣言的ルーティング層', tf=B, ts=9, title_dy=4.0 * mm)
c.setFont(R, 6.8); fill, border, txt = BLUE; c.setFillColor(GRAY)
c.drawCentredString(cx, y_router_top - gr_h + 2.4 * mm,
    'ロール別 URL（/member ・ /distributor ・ /advertiser ・ /admin）で画面を完全分離')
y_router_bot = y_router_top - gr_h

# arrow
y_prov_top = y_router_bot - 8.5 * mm
arrow_down(cx, y_router_bot, y_prov_top, 'watch / read（状態を購読）')

# Row3: Riverpod Providers（強調）
pr_w = 150 * mm
pr_h = 15 * mm
pr_x = (W - pr_w) / 2
fill, border, txt = YELLOW
c.setFillColor(fill); c.setStrokeColor(border); c.setLineWidth(1.6)
c.roundRect(pr_x, y_prov_top - pr_h, pr_w, pr_h, 2.5, fill=1, stroke=1)
c.setFillColor(txt); c.setFont(B, 9.5)
c.drawCentredString(cx, y_prov_top - 5 * mm, 'Riverpod Providers  ─  状態管理の中心層')
c.setFont(R, 6.8); c.setFillColor(GRAY)
c.drawCentredString(cx, y_prov_top - 9 * mm,
    'adList / filteredAds・memberAds（フィルタ＋ソート）/ favorites / adForm / account')
c.setFont(M, 6.6); c.setFillColor(colors.HexColor('#8A6A12'))
c.drawCentredString(cx, y_prov_top - 12.4 * mm,
    'リビルド範囲を Provider 単位で制御し、ロール横断のロジックを共有')
y_prov_bot = y_prov_top - pr_h

# arrow (双方向ラベル)
y_data_top = y_prov_bot - 8.5 * mm
arrow_down(cx, y_prov_bot, y_data_top, '取得・更新 / 永続化')

# Row4: データ層 3 box
d_gap = 4 * mm
d_w = (CW - d_gap * 2) / 3
d_h = 15 * mm
data_boxes = [
    (GREEN,  'AdRepository',     'モックデータの CRUD'),
    (GREEN,  'models（freezed）', 'Ad / AdFormState 等の不変モデル'),
    (GRAYB,  'SharedPreferences', 'お気に入りをローカル永続化'),
]
for i, (pal, t, s) in enumerate(data_boxes):
    bx = MARGIN + i * (d_w + d_gap)
    fill, border, txt = pal
    c.setFillColor(fill); c.setStrokeColor(border); c.setLineWidth(1)
    c.roundRect(bx, y_data_top - d_h, d_w, d_h, 2.5, fill=1, stroke=1)
    c.setFillColor(txt); c.setFont(B, 8.3)
    c.drawCentredString(bx + d_w / 2, y_data_top - 6 * mm, t)
    c.setFont(R, 6.6); c.setFillColor(GRAY)
    c.drawCentredString(bx + d_w / 2, y_data_top - 10 * mm, s)
y_data_bot = y_data_top - d_h

# 凡例
leg_y = y_data_bot - 6 * mm
legend = [('利用者ロール', BLUE), ('UI層（go_router）', BLUE),
          ('状態管理（Riverpod）', YELLOW), ('データ／モデル層', GREEN)]
lx = MARGIN
c.setFont(R, 7)
for name, pal in legend:
    fill, border, _ = pal
    c.setFillColor(fill); c.setStrokeColor(border); c.setLineWidth(0.8)
    c.rect(lx, leg_y, 3.2 * mm, 3.2 * mm, fill=1, stroke=1)
    c.setFillColor(GRAY)
    c.drawString(lx + 4.5 * mm, leg_y + 0.4 * mm, name)
    lx += 4.5 * mm + c.stringWidth(name, R, 7) + 7 * mm
y = leg_y - 6 * mm

# ════════════════════════════════════════════════════════
# 技術選定テーブル
# ════════════════════════════════════════════════════════
y = sec_label(y, '技術選定')
rows = [
    ('Flutter 3 / Dart ≥3.3', 'UI フレームワーク', 'iOS / Android / Web / macOS をワンソースで対応'),
    ('flutter_riverpod 2.6',  '状態管理',          'Provider 単位でリビルド範囲とスコープを制御'),
    ('go_router 14.8',        'ルーティング',       'ロール別 URL による宣言的な画面遷移'),
    ('freezed 2.5',           'モデル生成',         'イミュータブルなドメインモデルを自動生成'),
    ('shared_preferences 2.5','永続化',            'お気に入りをセッション跨ぎで保存'),
    ('google_fonts / intl',   '表示基盤',           'Noto Sans JP 統一・日付フォーマット'),
]
col = [44 * mm, 26 * mm, CW - 70 * mm]
hh = 6.2 * mm
rh = 6.0 * mm
# header
c.setFillColor(NAVY); c.rect(MARGIN, y - hh, CW, hh, fill=1, stroke=0)
c.setFont(B, 7.8); c.setFillColor(WHITE)
heads = ['採用技術', '役割', '採用理由 / 補足']
hx = MARGIN
for i, htxt in enumerate(heads):
    c.drawString(hx + 2.5 * mm, y - hh + 2.0 * mm, htxt)
    hx += col[i]
ry = y - hh
for i, (a, b, d) in enumerate(rows):
    if i % 2 == 0:
        c.setFillColor(colors.HexColor('#F3F6FA'))
        c.rect(MARGIN, ry - rh, CW, rh, fill=1, stroke=0)
    c.setStrokeColor(LINE); c.setLineWidth(0.3)
    c.line(MARGIN, ry - rh, MARGIN + CW, ry - rh)
    xx = MARGIN
    c.setFont(M, 7.6); c.setFillColor(colors.HexColor('#2E5E92'))
    c.drawString(xx + 2.5 * mm, ry - rh + 1.8 * mm, a); xx += col[0]
    c.setFont(M, 7.4); c.setFillColor(INK)
    c.drawString(xx + 2.5 * mm, ry - rh + 1.8 * mm, b); xx += col[1]
    c.setFont(R, 7.4); c.setFillColor(GRAY)
    c.drawString(xx + 2.5 * mm, ry - rh + 1.8 * mm, d)
    ry -= rh
c.setStrokeColor(LINE); c.setLineWidth(0.5)
c.rect(MARGIN, ry, CW, y - ry, fill=0, stroke=1)
y = ry - 5 * mm

# ════════════════════════════════════════════════════════
# ロール別画面構成
# ════════════════════════════════════════════════════════
y = sec_label(y, 'ロール別 画面構成')
role_cols = [
    ('会員',           BLUE,    ['ホーム', 'お気に入り', '通知', 'アカウント']),
    ('配信者（クラブ）', GREEN,   ['ホーム', 'お気に入り', 'クラブチーム', '配信履歴', '通知', 'アカウント']),
    ('広告主',         ORANGEB, ['ホーム', '広告投稿 / 編集', '掲載履歴', '通知', 'アカウント']),
    ('管理者',         PURPLE,  ['ダッシュボード']),
]
rc_gap = 4 * mm
rc_w = (CW - rc_gap * 3) / 4
max_n = max(len(s) for _, _, s in role_cols)
head_h = 6.5 * mm
body_h = max_n * 4.6 * mm + 2 * mm
for i, (name, pal, screens) in enumerate(role_cols):
    bx = MARGIN + i * (rc_w + rc_gap)
    fill, border, txt = pal
    c.setFillColor(border)
    c.roundRect(bx, y - head_h, rc_w, head_h, 2.5, fill=1, stroke=0)
    c.setFillColor(WHITE); c.setFont(B, 7.8)
    c.drawCentredString(bx + rc_w / 2, y - head_h + 1.9 * mm, name)
    c.setFillColor(fill); c.setStrokeColor(border); c.setLineWidth(0.8)
    c.rect(bx, y - head_h - body_h, rc_w, body_h, fill=1, stroke=1)
    c.setFont(R, 7.1); c.setFillColor(INK)
    for j, s in enumerate(screens):
        c.drawString(bx + 3 * mm, y - head_h - (j + 1) * 4.6 * mm + 1.2 * mm, '・' + s)
y = y - head_h - body_h - 5 * mm

# ════════════════════════════════════════════════════════
# メリット / デメリット（本方針について）
# ════════════════════════════════════════════════════════
y = sec_label(y, 'この実装方針の評価')
col_gap = 6 * mm
col_w = (CW - col_gap) / 2
merit_items = [
    'バックエンド未確定でも UI / UX と画面遷移を先行検証できる',
    'Repository を差し替えるだけで実 API 連携へ移行可能な構造',
    'ロールを URL で分離し、権限ごとの画面を独立して開発・確認',
    'Riverpod により状態とロジックを一元管理し再利用性が高い',
]
demerit_items = [
    'データはモックのみ。認証・決済・サーバ連携は未実装',
    'お気に入り以外の永続化は無く、再起動で状態が初期化',
    '実 API のレスポンス遅延・エラー処理は今後の検証課題',
    '本番運用にはバックエンド / インフラ方式の別途決定が必要',
]


def md_box(x, title, items, head_fill, head_border, mark, mark_color):
    n = len(items)
    bh = 7 * mm + n * 5.2 * mm + 2.5 * mm
    c.setFillColor(head_fill)
    c.roundRect(x, y - 7 * mm, col_w, 7 * mm, 2.5, fill=1, stroke=0)
    c.setFillColor(head_border); c.setFont(B, 8.8)
    c.drawString(x + 4 * mm, y - 7 * mm + 1.9 * mm, title)
    c.setFillColor(colors.HexColor('#FCFDFE'))
    c.setStrokeColor(head_border); c.setLineWidth(0.9)
    c.rect(x, y - bh, col_w, bh - 7 * mm, fill=1, stroke=1)
    c.rect(x, y - bh, col_w, bh, fill=0, stroke=1)
    ty = y - 7 * mm - 4.6 * mm
    for it in items:
        c.setFont(B, 8); c.setFillColor(mark_color)
        c.drawString(x + 3.5 * mm, ty, mark)
        c.setFont(R, 7.4); c.setFillColor(INK)
        _wrap_draw(x + 8 * mm, ty, it, col_w - 11 * mm)
        ty -= 5.2 * mm
    return bh


def _wrap_draw(x, ty, text, maxw):
    line = ''
    for ch in text:
        if c.stringWidth(line + ch, R, 7.4) > maxw and line:
            c.drawString(x, ty, line)
            ty -= 3.6 * mm
            line = ch
        else:
            line += ch
    if line:
        c.drawString(x, ty, line)


h1 = md_box(MARGIN, '◎ メリット', merit_items,
            colors.HexColor('#E5F1E4'), colors.HexColor('#3C7A2E'), '✓',
            colors.HexColor('#3C7A2E'))
h2 = md_box(MARGIN + col_w + col_gap, '△ デメリット / 今後の課題', demerit_items,
            colors.HexColor('#FBE5E5'), colors.HexColor('#B23B3B'), '!',
            colors.HexColor('#B23B3B'))
y = y - max(h1, h2) - 5 * mm

# ════════════════════════════════════════════════════════
# フッタ
# ════════════════════════════════════════════════════════
c.setFillColor(colors.HexColor('#F1F4F8'))
c.roundRect(MARGIN, 7 * mm, CW, 11 * mm, 2, fill=1, stroke=0)
c.setFont(R, 7); c.setFillColor(GRAY)
c.drawString(MARGIN + 3 * mm, 14 * mm,
    '※ 本資料はモック実装の方針確認を目的として作成。バックエンド連携・認証・決済・本番インフラ方式は対象外（別途検討）。')
c.setFont(R, 6.8); c.setFillColor(GRAYL)
c.drawString(MARGIN + 3 * mm, 9.6 * mm,
    'カリルネ ver 1.0.0 ／ 53 ファイル・約 5,800 行 ／ 作成日 2026-06-17')

c.save()
print('done')
