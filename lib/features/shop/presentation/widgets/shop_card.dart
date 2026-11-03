import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../core/widgets/status_toggle.dart';
import '../../domain/entities/shop_entity.dart';

class ShopCard extends StatelessWidget {
  final int index;
  final ShopEntity shop;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final ValueChanged<bool> onToggle;

  const ShopCard({
    super.key,
    required this.index,
    required this.shop,
    required this.onEdit,
    required this.onDelete,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) => Card(
        margin: EdgeInsets.zero,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 8, 12),
          child: Column(
            children: [
              Row(children: [
                Expanded(
                  child: Text('$index. ${shop.shopName}',
                      style: AppTextStyles.h2.copyWith(fontSize: 16)),
                ),
                IconButton(
                  onPressed: onDelete,
                  icon: const Icon(Icons.delete_outline,
                      color: AppColors.error, size: 20),
                ),
              ]),
              _InfoRow('Contact Person', shop.ownerName),
              _InfoRow('Mobile Number', '+91 ${shop.phone}'),
              _InfoRow('Email', shop.email),
              _InfoRow('Location', shop.address),
              _InfoRow('Added Date', DateFormatter.compact(shop.createdAt)),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.only(right: 8),
                child: Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                  OutlinedButton.icon(
                    onPressed: onEdit,
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size(0, 36),
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      backgroundColor: AppColors.surfaceAlt,
                    ),
                    icon: const Icon(Icons.edit_outlined, size: 16),
                    label: const Text('Edit', style: TextStyle(fontSize: 12)),
                  ),
                  const SizedBox(width: 8),
                  StatusToggle(
                    value: shop.isActive,
                    onLabel: 'Active',
                    offLabel: 'Inactive',
                    onChanged: onToggle,
                  ),
                ]),
              ),
            ],
          ),
        ),
      );
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  const _InfoRow(this.label, this.value);

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(top: 6, right: 8),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(label, style: AppTextStyles.caption),
          const SizedBox(width: 16),
          Expanded(
            child: Text(value,
                textAlign: TextAlign.end,
                style: AppTextStyles.caption.copyWith(color: AppColors.textPrimary)),
          ),
        ]),
      );
}
