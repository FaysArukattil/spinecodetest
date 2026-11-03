class Formatters {
  Formatters._();

  /// 20.0 -> "20", 2.5 -> "2.50"
  static String qty(num v) =>
      v == v.roundToDouble() ? v.toInt().toString() : v.toStringAsFixed(2);

  static String money(num v) => '₹${v.toStringAsFixed(2)}';
}
