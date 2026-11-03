import 'package:flutter/material.dart';

import 'app_theme.dart';

/// Indigo palette used by the Shop module (Figma).
class ShopColors {
  ShopColors._();
  static const primary = Color(0xFF5B72F5);
  static const primaryLight = Color(0xFFEEF0FF);
  static const primaryBorder = Color(0xFFC7CCF5);
}

/// Wraps a Shop screen so buttons and accents use the indigo palette.
class ShopTheme extends StatelessWidget {
  final Widget child;
  const ShopTheme({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final base = AppTheme.light;
    return Theme(
      data: base.copyWith(
        colorScheme: base.colorScheme.copyWith(primary: ShopColors.primary),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: ShopColors.primary,
            foregroundColor: Colors.white,
            elevation: 0,
            minimumSize: const Size.fromHeight(48),
            textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
      ),
      child: child,
    );
  }
}
