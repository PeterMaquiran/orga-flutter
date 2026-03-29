import 'package:flutter/material.dart';

/// Locale-aware week start and week math for the custom calendar.
abstract final class OrgaCalendarDateUtils {
  OrgaCalendarDateUtils._();

  static DateTime dateOnly(DateTime d) => DateTime(d.year, d.month, d.day);

  /// First day of the calendar week containing [date] (midnight).
  static DateTime startOfWeek(DateTime date, MaterialLocalizations loc) {
    final int fdow = loc.firstDayOfWeekIndex;
    final int dayIndex = date.weekday % 7;
    final int daysSinceWeekStart = (dayIndex - fdow + 7) % 7;
    return dateOnly(date).subtract(Duration(days: daysSinceWeekStart));
  }

  /// Whole weeks between the week of [a] and the week of [b] (can be negative).
  static int weekDifference(
    DateTime a,
    DateTime b,
    MaterialLocalizations loc,
  ) {
    final DateTime sa = startOfWeek(a, loc);
    final DateTime sb = startOfWeek(b, loc);
    return sb.difference(sa).inDays ~/ 7;
  }
}
