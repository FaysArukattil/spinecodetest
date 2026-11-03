import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/shop_theme.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/utils/snackbar_helper.dart';
import '../../../../core/widgets/confirm_dialog.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../order/presentation/providers/order_provider.dart';
import '../../../vegetable/domain/entities/vegetable_entity.dart';
import '../../../vegetable/presentation/providers/vegetable_provider.dart';
import '../../domain/entities/cart_item_entity.dart';
import '../providers/cart_provider.dart';
import '../widgets/cart_item_tile.dart';

class CartPage extends StatelessWidget {
  const CartPage({super.key});

  VegetableEntity? _live(List<VegetableEntity> vegs, String id) {
    for (final v in vegs) {
      if (v.id == id) return v;
    }
    return null;
  }

  double _maxQty(VegetableEntity? v) =>
      (v != null && v.isAvailable) ? v.stockQuantity : 0;

  /// Anything that would make the order fail on the server.
  String? _problem(List<CartItemEntity> items, List<VegetableEntity> vegs) {
    for (final i in items) {
      final max = _maxQty(_live(vegs, i.vegetableId));
      if (max <= 0) return '${i.name} is out of stock. Remove it to continue.';
      if (i.quantity > max) {
        return 'Only ${Formatters.qty(max)} ${i.unit} of ${i.name} available.';
      }
    }
    return null;
  }

  Future<void> _place(BuildContext context) async {
    final user = context.read<AuthProvider>().user;
    final cart = context.read<CartProvider>();
    final orders = context.read<OrderProvider>();
    final vegs = context.read<VegetableProvider>().items;
    if (user == null) return;

    if (cart.isEmpty) {
      SnackbarHelper.error(context, 'Your cart is empty.');
      return;
    }
    final problem = _problem(cart.items, vegs);
    if (problem != null) {
      SnackbarHelper.error(context, problem);
      return;
    }

    final yes = await ConfirmDialog.show(
      context,
      title: 'Place Order',
      message:
          'Place an order for ${cart.itemCount} item(s), total ${Formatters.money(cart.totalAmount)}?',
      confirmLabel: 'Place Order',
      color: ShopColors.primary,
    );
    if (!yes || !context.mounted) return;

    final order = cart.buildOrder(shopId: user.id, shopName: user.name);
    final err = await orders.placeOrder(order);
    if (!context.mounted) return;
    if (err != null) {
      SnackbarHelper.error(context, err);
      return;
    }

    cart.clear();
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            const Icon(Icons.check_circle_outline,
                size: 48, color: ShopColors.primary),
            const SizedBox(height: 12),
            Text('Order Placed Successfully!',
                textAlign: TextAlign.center,
                style: AppTextStyles.h2.copyWith(color: ShopColors.primary)),
            const SizedBox(height: 6),
            const Text(
              'Your order has been received and will be processed soon.',
              textAlign: TextAlign.center,
              style: AppTextStyles.caption,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Done'),
            ),
          ]),
        ),
      ),
    );
    if (!context.mounted) return;
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();
    final vegs = context.watch<VegetableProvider>().items;
    final busy = context.watch<OrderProvider>().isBusy;
    final items = cart.items;

    return ShopTheme(
      child: Scaffold(
        appBar: AppBar(title: const Text('My Cart', style: TextStyle(fontSize: 16))),
        body: items.isEmpty
            ? const EmptyState(
                message: 'Your cart is empty.\nAdd some vegetables to get started.',
                icon: Icons.shopping_cart_outlined,
              )
            : ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  for (final i in items) ...[
                    Builder(builder: (context) {
                      final live = _live(vegs, i.vegetableId);
                      return CartItemTile(
                        item: i,
                        maxQty: _maxQty(live),
                        onIncrease: live == null
                            ? null
                            : () {
                                final err = context.read<CartProvider>().increase(live);
                                if (err != null) SnackbarHelper.error(context, err);
                              },
                        onDecrease: () =>
                            context.read<CartProvider>().decrease(i.vegetableId),
                        onRemove: () =>
                            context.read<CartProvider>().remove(i.vegetableId),
                      );
                    }),
                    const SizedBox(height: 10),
                  ],
                  const SizedBox(height: 6),
                  _TotalBar('Total Items', Formatters.qty(cart.itemCount).padLeft(2, '0')),
                  const SizedBox(height: 8),
                  _TotalBar('Total Amount', Formatters.money(cart.totalAmount)),
                ],
              ),
        bottomNavigationBar: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
            child: Row(children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: busy ? null : () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: CustomButton(
                  label: 'Place Order',
                  isLoading: busy,
                  onPressed: items.isEmpty ? null : () => _place(context),
                ),
              ),
            ]),
          ),
        ),
      ),
    );
  }
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
