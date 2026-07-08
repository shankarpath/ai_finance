import 'package:intl/intl.dart';

final _rupee = NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 0);
final _rupeePaise =
    NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 2);
final _dayMonth = DateFormat('d MMM');
final _timeFmt = DateFormat('h:mm a');

/// ₹1,250 (no paise) — used for headline figures.
String formatRupees(num value) => _rupee.format(value);

/// ₹1,250.50 — used where precision matters (single transaction rows).
String formatRupeesPrecise(num value) => _rupeePaise.format(value);

/// "3 Jul"
String formatDayMonth(DateTime d) => _dayMonth.format(d);

/// "3 Jul, 7:30 PM"
String formatDateTime(DateTime d) => '${_dayMonth.format(d)}, ${_timeFmt.format(d)}';
