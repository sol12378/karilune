import 'package:flutter/material.dart';

import '../common/section_header.dart';
import '../featured/featured_ads_carousel.dart';
import '../layout/browse_home_layout.dart';
import '../member_admin_entry_banner.dart';
import '../sort_chips.dart';

/// 会員向けホームレイアウト（§3.2 閲覧ブロックのみ、オペレーター要素なし）。
///
/// - 注目エリア: [FeaturedAdsCarousel]
/// - カテゴリ: 左サイドバー（デスクトップ）/ チップ（狭幅）
/// - 実績パネル・モード切替・配信操作: なし
class MemberHomeLayout extends StatelessWidget {
  const MemberHomeLayout({
    super.key,
    required this.buildMain,
    this.showDemoAdminLink = true,
  });

  final Widget Function(double mainContentWidth) buildMain;
  final bool showDemoAdminLink;

  @override
  Widget build(BuildContext context) {
    return BrowseHomeLayout(
      featured: const FeaturedAdsCarousel(linkFrom: 'member'),
      showCategorySidebar: true,
      showPrefectureFilter: true,
      mainHeader: const Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SectionHeader(
            title: '配信中の広告',
            subtitle: 'カテゴリや並び替えで絞り込めます',
          ),
          SortChips(),
        ],
      ),
      buildMain: buildMain,
      footer: showDemoAdminLink ? const MemberDemoAdminLink() : null,
    );
  }
}
