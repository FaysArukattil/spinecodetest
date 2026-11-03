import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../core/utils/formatters.dart';
import '../../domain/entities/order_entity.dart';
import 'status_chip.dart';

/// Order summary card (Figma: "1. Shop name" + item rows + date).
class OrderCard extends StatelessWidget {
  final OrderEntity order;
  final int index;
  final VoidCallback onTap;
  final bool showShopName; // store sees shop name, shop sees order id
  final bool showStatus;

  const OrderCard({
    super.key,
    required this.order,
    required this.index,
    required this.onTap,
    this.showShopName = true,
    this.showStatus = true,
  });

  static const _maxRows = 5;

  @override
  Widget build(BuildContext context) {
    final shown = order.items.take(_maxRows).toList();
    final more = order.items.length - shown.length;

    return Card(
      margin: EdgeInsets.zero,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '$index. ${showShopName ? order.shopName : order.displayId}',
                        style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w600),
                      ),
                      if (!showShopName)
                        Padding(
                          padding: const EdgeInsets.only(top: 2),
                          child: Text(
                            '${order.items.length} items • ${DateFormatter.compact(order.createdAt)}',
                            style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                          ),
                        ),
                    ],
                  ),
                ),
                if (showStatus) StatusChip(order.status),
                const SizedBox(width: 4),
                const Icon(Icons.chevron_right, size: 18, color: AppColors.textSecondary),
              ]),
              const SizedBox(height: 6),
              for (var i = 0; i < shown.length; i++)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2),
                  child: Row(children: [
                    Expanded(
                      child: Text('${i + 1} ${shown[i].name}',
                          style: AppTextStyles.caption
                              .copyWith(color: AppColors.textPrimary)),
                    ),
                    Text('${Formatters.qty(shown[i].quantity)} ${shown[i].unit}',
                        style: AppTextStyles.caption
                            .copyWith(color: AppColors.textPrimary)),
                  ]),
                ),
              if (more > 0)
                Text('+$more more', style: AppTextStyles.caption),
              const SizedBox(height: 4),
              Align(
                alignment: Alignment.centerRight,
                child: Text(DateFormatter.compact(order.createdAt),
                    style: const TextStyle(fontSize: 10, color: AppColors.textSecondary)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
