import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../core/utils/formatters.dart';
import '../../domain/entities/order_entity.dart';
import 'status_chip.dart';

/// Shared by the Store and Shop "Order Details" screens (no scrolling of its own).
class OrderDetailBody extends StatelessWidget {
  final OrderEntity order;
  const OrderDetailBody({super.key, required this.order});

  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFFEEF0FF),
              border: Border.all(color: const Color(0xFFC7CCF5)),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(children: [
              _InfoRow(Icons.tag, 'Order ID', Text(order.displayId,
                  style: const TextStyle(color: AppColors.accent, fontSize: 12))),
              _InfoRow(Icons.flag_outlined, 'Status', StatusChip(order.status)),
              _InfoRow(Icons.storefront_outlined, 'Shop',
                  Text(order.shopName, style: const TextStyle(fontSize: 12))),
              _InfoRow(Icons.calendar_today_outlined, 'Order Date',
                  Text(DateFormatter.compact(order.createdAt),
                      style: const TextStyle(fontSize: 12))),
              _InfoRow(Icons.inventory_2_outlined, 'Items',
                  Text('${order.items.length} Items',
                      style: const TextStyle(fontSize: 12))),
            ]),
          ),
          const SizedBox(height: 24),
          const Text('Ordered items', style: AppTextStyles.h2),
          const SizedBox(height: 12),
          for (var i = 0; i < order.items.length; i++)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Expanded(
                  child: Text('${i + 1}   ${order.items[i].name}',
                      style: AppTextStyles.body.copyWith(fontSize: 13)),
                ),
                Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                  Text(
                      '${Formatters.qty(order.items[i].quantity)} ${order.items[i].unit}',
                      style: AppTextStyles.body.copyWith(fontSize: 13)),
                  Text(Formatters.money(order.items[i].lineTotal),
                      style: AppTextStyles.caption),
                ]),
              ]),
            ),
          const SizedBox(height: 8),
          _TotalBar('Total Items', order.items.length.toString().padLeft(2, '0')),
          const SizedBox(height: 8),
          _TotalBar('Total Amount', Formatters.money(order.totalAmount)),
        ],
      );
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final Widget value;
  const _InfoRow(this.icon, this.label, this.value);

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 5),
        child: Row(children: [
          Icon(icon, size: 16, color: AppColors.textSecondary),
          const SizedBox(width: 8),
          Text(label, style: AppTextStyles.caption),
          const Spacer(),
          value,
        ]),
      );
}

class _TotalBar extends StatelessWidget {
  final String label;
  final String value;
  const _TotalBar(this.label, this.value);

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: AppColors.primaryLight,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Row(children: [
          Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
          const Spacer(),
          Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
        ]),
      );
}
