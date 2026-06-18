import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../mock_data/categories_mock.dart';
import '../../providers/ad_list_provider.dart';
import '../../theme/breakpoints.dart';
import '../operator/category_sidebar.dart';

const double kCategorySidebarWidth = 200;
const double kPerformancePanelWidth = 240;

/// §3.2 閲覧系レイアウト骨格（注目/お勧め + カテゴリ + メイン）。
///
/// 会員・配信で共有。[trailingPanel] に実績パネル等をロール別に付与する。
/// 設計原則は [ScreenRoleConfig] を参照。
class BrowseHomeLayout extends ConsumerWidget {
  const BrowseHomeLayout({
    super.key,
    this.featured,
    this.showCategorySidebar = true,
    this.showPrefectureFilter = false,
    this.mainHeader,
    required this.buildMain,
    this.trailingPanel,
    this.compactTrailingPanel,
    this.footer,
  });

  final Widget? featured;
  final bool showCategorySidebar;
  final bool showPrefectureFilter;
  final Widget? mainHeader;
  final Widget Function(double mainContentWidth) buildMain;
  final Widget? trailingPanel;
  final Widget? compactTrailingPanel;
  final Widget? footer;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final useSidebar =
            showCategorySidebar && width >= Breakpoints.desktop;
        final useTrailingPanel =
            trailingPanel != null && width >= Breakpoints.desktop;
        final showCompactTrailing = compactTrailingPanel != null &&
            width < Breakpoints.desktop;

        final mainContentWidth = width -
            (useSidebar ? kCategorySidebarWidth : 0) -
            (useTrailingPanel ? kPerformancePanelWidth : 0);

        return CustomScrollView(
          slivers: [
            if (featured != null)
              SliverToBoxAdapter(child: featured!),
            if (showCompactTrailing)
              SliverToBoxAdapter(child: compactTrailingPanel!),
            if (showCategorySidebar && !useSidebar) ...[
              const SliverToBoxAdapter(child: CategorySidebarCompact()),
              if (showPrefectureFilter)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(12, 4, 12, 8),
                    child: CompactPrefectureFilter(),
                  ),
                ),
            ],
            SliverToBoxAdapter(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (useSidebar)
                    CategorySidebar(
                      showPrefectureFilter: showPrefectureFilter,
                      shrinkWrap: true,
                    ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        if (mainHeader != null) mainHeader!,
                        buildMain(mainContentWidth),
                      ],
                    ),
                  ),
                  if (useTrailingPanel) trailingPanel!,
                ],
              ),
            ),
            if (footer != null) SliverToBoxAdapter(child: footer!),
          ],
        );
      },
    );
  }
}

class CompactPrefectureFilter extends ConsumerWidget {
  const CompactPrefectureFilter({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return DropdownButtonFormField<String>(
      initialValue: ref.watch(selectedPrefectureProvider),
      decoration: const InputDecoration(
        labelText: '地域で絞り込み',
        border: OutlineInputBorder(),
        isDense: true,
      ),
      items: [
        for (final prefecture in prefectures)
          DropdownMenuItem(
            value: prefecture,
            child: Text(prefecture),
          ),
      ],
      onChanged: (value) {
        if (value != null) {
          ref.read(selectedPrefectureProvider.notifier).state = value;
        }
      },
    );
  }
}
