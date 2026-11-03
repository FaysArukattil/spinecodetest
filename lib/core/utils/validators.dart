class Validators {
  Validators._();

  static String? required(String? v, [String field = 'This field']) =>
      (v == null || v.trim().isEmpty) ? '$field is required' : null;

  static String? email(String? v) {
    if (v == null || v.trim().isEmpty) return 'Email is required';
    final ok = RegExp(r'^[\w.+-]+@[\w-]+(\.[\w-]+)+$').hasMatch(v.trim());
    return ok ? null : 'Enter a valid email';
  }

  static String? password(String? v) {
    if (v == null || v.isEmpty) return 'Password is required';
    if (v.length < 6) return 'Password must be at least 6 characters';
    return null;
  }

  static String? phone(String? v) {
    if (v == null || v.trim().isEmpty) return 'Mobile number is required';
    return RegExp(r'^[6-9]\d{9}$').hasMatch(v.trim())
        ? null
        : 'Enter a valid 10-digit mobile number';
  }

  static String? name(String? v, [String field = 'Name']) {
    if (v == null || v.trim().isEmpty) return '$field is required';
    if (v.trim().length < 2) return '$field is too short';
    return null;
  }

  static String? sortNumber(String? v) {
    if (v == null || v.trim().isEmpty) return 'Sort number is required';
    final n = int.tryParse(v.trim());
    if (n == null) return 'Enter a whole number';
    if (n < 1) return 'Must be 1 or more';
    return null;
  }

  static String? price(String? v) {
    if (v == null || v.trim().isEmpty) return 'Price is required';
    final n = double.tryParse(v.trim());
    if (n == null) return 'Enter a valid number';
    if (n <= 0) return 'Price must be greater than 0';
    return null;
  }

  /// Stock can be 0 but never negative.
  static String? stock(String? v) {
    if (v == null || v.trim().isEmpty) return 'Stock is required';
    final n = double.tryParse(v.trim());
    if (n == null) return 'Enter a valid number';
    if (n < 0) return 'Stock cannot be negative';
    return null;
  }

  static String? wholeNumber(String? v) {
    final n = double.tryParse((v ?? '').trim());
    if (n != null && n % 1 != 0) return 'Enter a whole number for this unit';
    return null;
  }
}
