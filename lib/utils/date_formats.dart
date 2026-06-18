import 'package:intl/intl.dart';

/// ビルドごとに DateFormat を生成しないよう、共有インスタンスを保持する。
abstract final class AppDateFormats {
  static final monthDay = DateFormat('MM/dd');
  static final yearMonthDay = DateFormat('yyyy/MM/dd');
  static final monthDayTime = DateFormat('MM/dd HH:mm');
}
