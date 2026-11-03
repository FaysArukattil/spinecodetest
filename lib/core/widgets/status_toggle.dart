import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// Green "Available/Active" / red "Unavailable/Inactive" pill with a switch.
class StatusToggle extends StatelessWidget {
  final bool value;
  final String onLabel;
  final String offLabel;
  final ValueChanged<bool> onChanged;

  const StatusToggle({
    super.key,
    required this.value,
    required this.onLabel,
    required this.offLabel,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final color = value ? AppColors.success : AppColors.error;
    return Container(
      height: 36,
      padding: const EdgeInsets.only(left: 12, right: 2),
      decoration: BoxDecoration(
        color: value ? AppColors.successLight : AppColors.errorLight,
        border: Border.all(color: color.withValues(alpha: 0.4)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(value ? onLabel : offLabel,
              style: TextStyle(color: color, fontSize: 12)),
          const SizedBox(width: 4),
          Transform.scale(
            scale: 0.75,
            child: Switch(
              value: value,
              onChanged: onChanged,
              thumbColor: const WidgetStatePropertyAll(Colors.white),
              trackColor: WidgetStatePropertyAll(color),
              trackOutlineColor: const WidgetStatePropertyAll(Colors.transparent),
            ),
          ),
        ],
      ),
    );
  }
}
