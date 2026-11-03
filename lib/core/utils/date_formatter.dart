import 'package:intl/intl.dart';

class DateFormatter {
  DateFormatter._();
  static String date(DateTime d) => DateFormat('dd MMM yyyy').format(d);
  static String dateTime(DateTime d) =>
      DateFormat('dd MMM yyyy, hh:mm a').format(d);
}
