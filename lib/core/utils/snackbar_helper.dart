import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

class SnackbarHelper {
  SnackbarHelper._();

  static void error(BuildContext c, String m) => _show(c, m, AppColors.error);
  static void success(BuildContext c, String m) =>
      _show(c, m, AppColors.success);

  static void _show(BuildContext c, String m, Color color) {
    ScaffoldMessenger.of(c)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(m),
          backgroundColor: color,
          behavior: SnackBarBehavior.floating,
        ),
      );
  }
}
