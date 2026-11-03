import 'package:flutter/material.dart';

import '../constants/app_constants.dart';
import '../theme/app_colors.dart';

class AppLogo extends StatelessWidget {
  final double? width;
  final double? height;
  const AppLogo({super.key, this.width = 220, this.height});

  @override
  Widget build(BuildContext context) => Image.asset(
    'assets/images/logo.png',
    width: width,
    height: height,
    errorBuilder: (context, error, stackTrace) => Text(
      AppConstants.appName,
      style: const TextStyle(
        fontSize: 32,
        fontWeight: FontWeight.w800,
        color: AppColors.brandGreen,
      ),
    ),
  );
}
