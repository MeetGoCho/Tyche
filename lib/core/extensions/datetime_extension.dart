import 'package:intl/intl.dart';

extension DateTimeExtension on DateTime {
  String toApiFormat() => DateFormat('yyyy-MM-dd').format(this);

  String toDisplayFormat() => DateFormat('MM/dd HH:mm').format(this);

  String toFullDisplayFormat() => DateFormat('yyyy-MM-dd HH:mm:ss').format(this);

  DateTime startOfDay() => DateTime(year, month, day);

  DateTime endOfDay() => DateTime(year, month, day, 23, 59, 59);

  bool isSameDay(DateTime other) =>
      year == other.year && month == other.month && day == other.day;
}
