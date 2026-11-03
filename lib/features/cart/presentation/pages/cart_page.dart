import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/shop_theme.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/utils/snackbar_helper.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../order/presentation/pages/order_summary_page.dart';
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
                  onPressed: items.isEmpty
                      ? null
                      : () {
                          final problem = _problem(items, vegs);
                          if (problem != null) {
                            SnackbarHelper.error(context, problem);
                            return;
                          }
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const OrderSummaryPage(),
                            ),
                          );
                        },
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
