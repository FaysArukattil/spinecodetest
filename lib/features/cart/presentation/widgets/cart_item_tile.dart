import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/shop_theme.dart';
import '../../../../core/utils/formatters.dart';
import '../../domain/entities/cart_item_entity.dart';
import 'quantity_stepper.dart';

class CartItemTile extends StatelessWidget {
  final CartItemEntity item;

  /// Live stock for this vegetable (0 if it is out of stock or deleted).
  final double maxQty;
  final VoidCallback? onIncrease;
  final VoidCallback onDecrease;
  final VoidCallback onRemove;

  const CartItemTile({
    super.key,
    required this.item,
    required this.maxQty,
    required this.onIncrease,
    required this.onDecrease,
    required this.onRemove,
  });

  String? get _warning {
    if (maxQty <= 0) return 'Out of stock - remove this item';
    if (item.quantity > maxQty) {
      return 'Only ${Formatters.qty(maxQty)} ${item.unit} available';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final warning = _warning;
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              Expanded(
                child: Text(item.name,
                    style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w700)),
              ),
              InkWell(
                onTap: onRemove,
                customBorder: const CircleBorder(),
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                    color: AppColors.errorLight,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.close, size: 14, color: AppColors.error),
                ),
              ),
            ]),
            const SizedBox(height: 8),
            Row(children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  border: Border.all(color: ShopColors.primary),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(item.unit,
                    style: const TextStyle(fontSize: 12, color: ShopColors.primary)),
              ),
              const SizedBox(width: 10),
              Text('${Formatters.money(item.price)} / ${item.unit}',
                  style: AppTextStyles.caption),
              const Spacer(),
              QuantityStepper(
                quantity: item.quantity,
                onMinus: item.quantity > 1 ? onDecrease : null,
                onPlus: onIncrease,
              ),
            ]),
            const SizedBox(height: 6),
            Align(
              alignment: Alignment.centerRight,
              child: Text(Formatters.money(item.lineTotal),
                  style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w600)),
            ),
            if (warning != null)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(warning,
                    style: const TextStyle(fontSize: 12, color: AppColors.error)),
              ),
          ],
        ),
      ),
    );
  }
}
