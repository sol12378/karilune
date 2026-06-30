import 'package:flutter/material.dart';

import '../../../theme/breakpoints.dart';
import '../ideal_theme.dart';

/// 会員向けコンテンツの幅制御（スマホはフィード幅、PCはBrowseレイアウト用）。
class MemberContentFrame extends StatelessWidget {
  const MemberContentFrame({
    super.key,
    required this.child,
    this.style = MemberFrameStyle.mobileFeed,
  });

  final Widget child;
  final MemberFrameStyle style;

  static bool isDesktop(double width) =>
      width >= Breakpoints.desktop;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        switch (style) {
          case MemberFrameStyle.mobileFeed:
            return Align(
              alignment: Alignment.topCenter,
              child: ConstrainedBox(
                constraints: const BoxConstraints(
                  maxWidth: IdealSpacing.memberMobileMaxWidth,
                ),
                child: child,
              ),
            );
          case MemberFrameStyle.detail:
            return Align(
              alignment: Alignment.topCenter,
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: isDesktop(constraints.maxWidth)
                      ? IdealSpacing.memberDetailDesktopMaxWidth
                      : IdealSpacing.memberMobileMaxWidth,
                ),
                child: child,
              ),
            );
          case MemberFrameStyle.favoritesMobile:
            return Align(
              alignment: Alignment.topCenter,
              child: ConstrainedBox(
                constraints: const BoxConstraints(
                  maxWidth: IdealSpacing.memberMobileMaxWidth,
                ),
                child: child,
              ),
            );
          case MemberFrameStyle.favoritesDesktop:
            return Align(
              alignment: Alignment.topCenter,
              child: ConstrainedBox(
                constraints: const BoxConstraints(
                  maxWidth: IdealSpacing.memberDesktopMaxWidth,
                ),
                child: child,
              ),
            );
        }
      },
    );
  }
}

enum MemberFrameStyle {
  mobileFeed,
  detail,
  favoritesMobile,
  favoritesDesktop,
}
