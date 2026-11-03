import 'package:intl/intl.dart';

class Formatters {
  Formatters._();

  static final _money = NumberFormat.currency(symbol: '₹', decimalDigits: 2);

  static String money(num v) => _money.format(v);

  static String qty(num v) =>
      v == v.roundToDouble() ? v.toInt().toString() : v.toString();

  static String qtyUnit(num v, String unit) => '${qty(v)} $unit';

  static String pad2(int n) => n.toString().padLeft(2, '0');

  static String orderId(String id) =>
      'ORD-${(id.length >= 6 ? id.substring(0, 6) : id).toUpperCase()}';
}
