import 'package:flutter/material.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_colors.dart';

class StatusChip extends StatelessWidget {
  final String status;
  const StatusChip(this.status, {super.key});

  Color get _color {
    switch (status) {
      case AppConstants.orderApproved:
        return AppColors.accent;
      case AppConstants.orderRejected:
        return AppColors.error;
      case AppConstants.orderCompleted:
        return AppColors.success;
      case AppConstants.orderCancelled:
        return AppColors.textSecondary;
      default:
        return const Color(0xFFB7791F); // Pending
    }
  }

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
          color: _color.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Text(status,
            style: TextStyle(color: _color, fontSize: 11, fontWeight: FontWeight.w600)),
      );
}
