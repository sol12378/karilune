class Breakpoints {
  static const double mobile = 600;
  static const double desktop = 900;
  static const double wide = 1200;
}

class Responsive {
  static bool useBottomNav(double width) => width < Breakpoints.desktop;

  static bool useNavigationRail(double width) => width >= Breakpoints.desktop;

  static int gridColumns(double width) {
    if (width >= Breakpoints.desktop) return 3;
    if (width >= Breakpoints.mobile) return 2;
    return 1;
  }
}
