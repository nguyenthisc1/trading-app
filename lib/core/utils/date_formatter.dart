import 'package:intl/intl.dart';

class DateFormatter {
  DateFormatter._();

  static final _dateFormat = DateFormat('MMM dd, yyyy', 'en_US');
  static final _timeFormat = DateFormat('HH:mm', 'en_US');
  static final _dateTimeFormat = DateFormat('MMM dd, HH:mm', 'en_US');
  static final _chartFormat = DateFormat('MM/dd HH:mm', 'en_US');
  static final _dayFormat = DateFormat('MMM dd', 'en_US');

  static String formatDate(DateTime date) => _dateFormat.format(date);

  static String formatTime(DateTime date) => _timeFormat.format(date);

  static String formatDateTime(DateTime date) => _dateTimeFormat.format(date);

  static String formatChartLabel(DateTime date) => _chartFormat.format(date);

  static String formatDay(DateTime date) => _dayFormat.format(date);

  static String formatRelative(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);
    if (diff.inSeconds < 60) return 'just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return _dateFormat.format(date);
  }
}
