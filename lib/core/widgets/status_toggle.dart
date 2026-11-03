import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

class StatusToggle extends StatelessWidget {
  final bool value;
  final ValueChanged<bool> onChanged;
  final String activeLabel;
  final String inactiveLabel;

  const StatusToggle({
    super.key,
    required this.value,
    required this.onChanged,
    this.activeLabel = 'Available',
    this.inactiveLabel = 'Unavailable',
  });

  @override
  Widget build(BuildContext context) {
    final color = value ? AppColors.success : AppColors.error;
    return Container(
      padding: const EdgeInsets.only(left: 12, right: 4),
      decoration: BoxDecoration(
        color: value ? AppColors.successLight : AppColors.errorLight,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            value ? activeLabel : inactiveLabel,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
          Transform.scale(
            scale: 0.8,
            child: Switch(
              value: value,
              onChanged: onChanged,
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              thumbColor: const WidgetStatePropertyAll(Colors.white),
              trackColor: WidgetStatePropertyAll(color),
              trackOutlineColor:
                  const WidgetStatePropertyAll(Colors.transparent),
            ),
          ),
        ],
      ),
    );
  }
}
