import 'package:flutter/material.dart';

import 'app_colors.dart';

class AppTextStyles {
  AppTextStyles._();
  // TODO: set fontFamily from Figma in app_theme.dart
  static const h1 = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
  );
  static const h2 = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );
  static const body = TextStyle(fontSize: 14, color: AppColors.textPrimary);
  static const caption = TextStyle(
    fontSize: 12,
    color: AppColors.textSecondary,
  );
  static const button = TextStyle(fontSize: 16, fontWeight: FontWeight.w600);
}
