import 'package:flutter/material.dart';

/// HTML モック（consumer.css / common.css）の余白・角丸を Flutter 定数化。
abstract final class IdealSpacing {
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 24;

  static const double feedPadding = 12;
  static const double feedGap = 12;
  static const double cardPaddingH = 14;
  static const double cardPaddingV = 10;
  static const double bottomNavClearance = 80;

  /// スマホ会員画面の最大幅（HTML `.member-app` 準拠）
  static const double memberMobileMaxWidth = 480;
  static const double memberDesktopMaxWidth = 1200;
  static const double memberDetailDesktopMaxWidth = 560;
}

abstract final class IdealRadii {
  static const double card = 12;
  static const double chip = 4;
  static const double button = 8;
  static const double avatar = 20;
}

abstract final class IdealShadows {
  static List<BoxShadow> get card => [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.08),
          blurRadius: 3,
          offset: const Offset(0, 1),
        ),
      ];
}
