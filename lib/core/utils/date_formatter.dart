import 'package:intl/intl.dart';

class DateFormatter {
  DateFormatter._();
  static String date(DateTime d) => DateFormat('dd MMM yyyy').format(d);
  static String dateTime(DateTime d) => DateFormat('dd MMM yyyy, hh:mm a').format(d);

  /// Figma style: 24/11/2025, 02:30am
  static String compact(DateTime d) =>
      '${DateFormat('dd/MM/yyyy, hh:mm').format(d)}${DateFormat('a').format(d).toLowerCase()}';
}
