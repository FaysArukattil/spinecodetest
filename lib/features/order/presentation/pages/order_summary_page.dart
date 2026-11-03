import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/shop_theme.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/utils/snackbar_helper.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../cart/presentation/providers/cart_provider.dart';
import '../../../vegetable/presentation/providers/vegetable_provider.dart';
import '../providers/order_provider.dart';

/// Figma Screen 6: Summary / Confirm Order screen.
class OrderSummaryPage extends StatelessWidget {
  final DateTime? scheduledDate;

  const OrderSummaryPage({super.key, this.scheduledDate});

  Future<void> _confirm(BuildContext context) async {
    final auth = context.read<AuthProvider>();
    final cart = context.read<CartProvider>();
    final vegs = context.read<VegetableProvider>().items;
    final orderP = context.read<OrderProvider>();

    final user = auth.user;
    if (user == null) {
      SnackbarHelper.error(context, 'You must be logged in.');
      return;
    }

    // Pre-flight check: ensure no items exceed current live stock
    for (final item in cart.items) {
      final v = vegs.where((e) => e.id == item.vegetableId).firstOrNull;
      if (v == null || !v.isAvailable || v.stockQuantity < item.quantity) {
        final available = v == null || !v.isAvailable ? 0.0 : v.stockQuantity;
        SnackbarHelper.error(
          context,
          'Insufficient stock for ${item.name}. Available: ${Formatters.qty(available)} ${item.unit}',
        );
        return;
      }
    }

    final order = cart.buildOrder(shopId: user.id, shopName: user.name);
    final err = await orderP.placeOrder(order);

    if (!context.mounted) return;

    if (err != null) {
      SnackbarHelper.error(context, err);
      return;
    }

    // Success! Clear cart
    cart.clear();

    // Show Figma "Order Placed Successfully!" card dialog
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 68,
                height: 68,
                decoration: const BoxDecoration(
                  color: AppColors.successLight,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check, size: 40, color: AppColors.success),
              ),
              const SizedBox(height: 16),
              const Text(
                'Order Placed Successfully!',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 8),
              const Text(
                'Your order has been submitted to Fresh Vegetables Store for approval.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: CustomButton(
                  label: 'Done',
                  onPressed: () {
                    Navigator.pop(ctx); // close dialog
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );

    if (!context.mounted) return;
    // Pop back to shop home / orders tab
    Navigator.of(context).popUntil((route) => route.isFirst);
  }

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();
    final user = context.watch<AuthProvider>().user;
    final busy = context.watch<OrderProvider>().isBusy;
    final items = cart.items;

    final dateDisplay = scheduledDate != null
        ? DateFormat('dd MMM yyyy').format(scheduledDate!)
        : DateFormat('dd MMM yyyy').format(DateTime.now());

    return ShopTheme(
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Confirm Order', style: TextStyle(fontSize: 16)),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Figma Tinted Order Card
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: ShopColors.primaryLight,
                border: Border.all(color: ShopColors.primaryBorder),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  _SummaryRow(
                    icon: Icons.storefront_outlined,
                    label: 'Store',
                    value: 'Fresh Vegetables Store',
                  ),
                  const SizedBox(height: 8),
                  _SummaryRow(
                    icon: Icons.person_outline,
                    label: 'Shop Name',
                    value: user?.name ?? 'Shop',
                  ),
                  const SizedBox(height: 8),
                  _SummaryRow(
                    icon: Icons.calendar_today_outlined,
                    label: scheduledDate != null ? 'Delivery Date' : 'Order Date',
                    value: dateDisplay,
                  ),
                  const SizedBox(height: 8),
                  _SummaryRow(
                    icon: Icons.inventory_2_outlined,
                    label: 'Items',
                    value: '${items.length} Items',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            const Text('Ordered items', style: AppTextStyles.h2),
            const SizedBox(height: 12),
            for (var i = 0; i < items.length; i++)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        '${i + 1}   ${items[i].name}',
                        style: AppTextStyles.body.copyWith(fontSize: 13),
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '${Formatters.qty(items[i].quantity)} ${items[i].unit}',
                          style: AppTextStyles.body.copyWith(fontSize: 13),
                        ),
                        Text(
                          Formatters.money(items[i].lineTotal),
                          style: AppTextStyles.caption,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: AppColors.surfaceAlt,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Total Items', style: AppTextStyles.caption),
                  Text(
                    items.length.toString().padLeft(2, '0'),
                    style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w700),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: AppColors.surfaceAlt,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Total Amount', style: AppTextStyles.caption),
                  Text(
                    Formatters.money(cart.totalAmount),
                    style: AppTextStyles.body.copyWith(
                      fontWeight: FontWeight.w700,
                      color: ShopColors.primary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        bottomNavigationBar: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: busy ? null : () => Navigator.pop(context),
                    child: const Text('Edit Order'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: CustomButton(
                    label: 'Confirm Order',
                    isLoading: busy,
                    onPressed: items.isEmpty ? null : () => _confirm(context),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _SummaryRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) => Row(
        children: [
          Icon(icon, size: 16, color: ShopColors.primary),
          const SizedBox(width: 8),
          Text(label, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
          const Spacer(),
          Text(
            value,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
          ),
        ],
      );
}
