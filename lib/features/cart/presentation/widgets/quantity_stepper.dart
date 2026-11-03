import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/formatters.dart';

/// [-]  1  [+]  control. Pass null to disable a button.
class QuantityStepper extends StatelessWidget {
  final double quantity;
  final VoidCallback? onMinus;
  final VoidCallback? onPlus;

  const QuantityStepper({
    super.key,
    required this.quantity,
    required this.onMinus,
    required this.onPlus,
  });

  @override
  Widget build(BuildContext context) => Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _StepButton(Icons.remove, onMinus),
          Container(
            width: 48,
            height: 30,
            margin: const EdgeInsets.symmetric(horizontal: 6),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.border),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              Formatters.qty(quantity),
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
            ),
          ),
          _StepButton(Icons.add, onPlus),
        ],
      );
}

class _StepButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;
  const _StepButton(this.icon, this.onTap);

  @override
  Widget build(BuildContext context) => InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(6),
        child: Container(
          width: 30,
          height: 30,
          decoration: BoxDecoration(
            color: AppColors.primaryLight,
            border: Border.all(color: AppColors.border),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Icon(
            icon,
            size: 16,
            color: onTap == null ? AppColors.border : AppColors.textPrimary,
          ),
        ),
      );
}
