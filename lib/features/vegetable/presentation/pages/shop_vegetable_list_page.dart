import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/shop_theme.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/utils/snackbar_helper.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/error_state.dart';
import '../../../../core/widgets/loading_indicator.dart';
import '../../../cart/presentation/providers/cart_provider.dart';
import '../../../cart/presentation/widgets/quantity_stepper.dart';
import '../../../order/presentation/providers/order_provider.dart';
import '../../domain/entities/vegetable_entity.dart';
import '../providers/vegetable_provider.dart';

/// Shop home tab: browse vegetables, search, add to cart.
class ShopVegetableListPage extends StatefulWidget {
  const ShopVegetableListPage({super.key});
  @override
  State<ShopVegetableListPage> createState() => _ShopVegetableListPageState();
}

class _ShopVegetableListPageState extends State<ShopVegetableListPage> {
  String _query = '';
  DateTime? _scheduledDate;

  void _repeatLastOrder() {
    final recent = context.read<OrderProvider>().orders.firstOrNull;
    if (recent == null) {
      SnackbarHelper.error(context, 'No previous order found to repeat.');
      return;
    }
    final vegs = context.read<VegetableProvider>().items;
    final cart = context.read<CartProvider>();
    int added = 0;
    for (final item in recent.items) {
      final v = vegs.where((e) => e.id == item.vegetableId).firstOrNull;
      if (v != null && v.isAvailable && v.stockQuantity > 0) {
        cart.add(v);
        added++;
      }
    }
    if (added > 0) {
      SnackbarHelper.success(context, 'Added $added item(s) from your last order to cart.');
    } else {
      SnackbarHelper.error(context, 'Items from last order are currently out of stock.');
    }
  }

  Future<void> _scheduleAdvanceOrder() async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now().add(const Duration(days: 1)),
      lastDate: DateTime.now().add(const Duration(days: 30)),
    );
    if (date != null && mounted) {
      setState(() => _scheduledDate = date);
      SnackbarHelper.success(
        context,
        'Advance delivery scheduled for ${DateFormat('dd MMM yyyy').format(date)}',
      );
    }
  }

  void _showChangeStoreDialog() {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Connected Store', style: TextStyle(fontSize: 16)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Selected Store Depot:',
              style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: ShopColors.primaryLight,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: ShopColors.primaryBorder),
              ),
              child: const Row(
                children: [
                  Icon(Icons.store, color: ShopColors.primary),
                  SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Fresh Vegetables Store',
                            style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
                        Text('Main Central Wholesale Depot',
                            style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                      ],
                    ),
                  ),
                  Icon(Icons.check_circle, color: ShopColors.primary, size: 20),
                ],
              ),
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final p = context.watch<VegetableProvider>();
    final q = _query.trim().toLowerCase();
    final list = p.items.where((v) => v.name.toLowerCase().contains(q)).toList();

    return Column(children: [
      // Store Row (Figma: Store Info + Change Store button)
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        color: AppColors.surfaceAlt,
        child: Row(
          children: [
            const Icon(Icons.storefront_outlined, size: 16, color: AppColors.textSecondary),
            const SizedBox(width: 6),
            const Expanded(
              child: Text(
                'Fresh Vegetables Store',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
              ),
            ),
            GestureDetector(
              onTap: _showChangeStoreDialog,
              child: const Text(
                'Change store',
                style: TextStyle(
                  fontSize: 11,
                  color: ShopColors.primary,
                  fontWeight: FontWeight.w600,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
          ],
        ),
      ),

      // Figma Banners Row: Advance Order (Yellow) & Repeat Order (Green)
      Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
        child: Row(
          children: [
            Expanded(
              child: InkWell(
                onTap: _scheduleAdvanceOrder,
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF7ED),
                    border: Border.all(color: const Color(0xFFFED7AA)),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    children: [
                      const CircleAvatar(
                        radius: 14,
                        backgroundColor: AppColors.statYellow,
                        child: Icon(Icons.event_available, color: Colors.white, size: 16),
                      ),
                      SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Order in advance',
                              style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700),
                            ),
                            Text(
                              _scheduledDate != null
                                  ? DateFormat('dd MMM').format(_scheduledDate!)
                                  : 'Schedule delivery',
                              style: const TextStyle(fontSize: 10, color: AppColors.textSecondary),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: InkWell(
                onTap: _repeatLastOrder,
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF0FDF4),
                    border: Border.all(color: const Color(0xFFBBF7D0)),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Row(
                    children: [
                      CircleAvatar(
                        radius: 14,
                        backgroundColor: AppColors.success,
                        child: Icon(Icons.replay, color: Colors.white, size: 16),
                      ),
                      SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Repeat last order',
                              style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700),
                            ),
                            Text(
                              'Quick 1-tap reorder',
                              style: TextStyle(fontSize: 10, color: AppColors.textSecondary),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),

      Padding(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
        child: TextField(
          onChanged: (v) => setState(() => _query = v),
          decoration: const InputDecoration(
            hintText: 'Search vegetables...',
            prefixIcon: Icon(Icons.search, size: 20),
            isDense: true,
          ),
        ),
      ),
      Expanded(
        child: p.isLoading
            ? const LoadingIndicator()
            : p.error != null
                ? ErrorState(message: p.error!, onRetry: () => p.start(force: true))
                : list.isEmpty
                    ? EmptyState(
                        message: q.isEmpty
                            ? 'No vegetables available yet.'
                            : 'No vegetables match "$_query".',
                        icon: Icons.eco_outlined,
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
                        itemCount: list.length,
                        separatorBuilder: (_, _) => const SizedBox(height: 10),
                        itemBuilder: (_, i) => _VegTile(list[i]),
                      ),
      ),
    ]);
  }
}

class _VegTile extends StatelessWidget {
  final VegetableEntity veg;
  const _VegTile(this.veg);

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();
    final out = !veg.isAvailable || veg.stockQuantity <= 0;
    final qty = cart.quantityOf(veg.id);
    final low = !out && veg.stockQuantity <= 5;

    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.successLight,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.eco, color: AppColors.success),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(veg.name,
                  style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w700)),
              const SizedBox(height: 4),
              Row(children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    border: Border.all(
                        color: out ? AppColors.border : ShopColors.primary),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(veg.unit,
                      style: TextStyle(
                          fontSize: 11,
                          color: out ? AppColors.textSecondary : ShopColors.primary)),
                ),
                const SizedBox(width: 8),
                Text('${Formatters.money(veg.price)} / ${veg.unit}',
                    style: AppTextStyles.caption),
              ]),
              const SizedBox(height: 2),
              if (!out)
                Text(
                  low
                      ? 'Only ${Formatters.qty(veg.stockQuantity)} ${veg.unit} left'
                      : 'In stock: ${Formatters.qty(veg.stockQuantity)} ${veg.unit}',
                  style: TextStyle(
                    fontSize: 11,
                    color: low ? const Color(0xFFB7791F) : AppColors.textSecondary,
                  ),
                ),
            ]),
          ),
          const SizedBox(width: 8),
          if (out)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.textSecondary,
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Text('Out of Stock',
                  style: TextStyle(color: Colors.white, fontSize: 11)),
            )
          else if (qty > 0)
            QuantityStepper(
              quantity: qty,
              onMinus: () => context.read<CartProvider>().decrease(veg.id),
              onPlus: () {
                final err = context.read<CartProvider>().increase(veg);
                if (err != null) SnackbarHelper.error(context, err);
              },
            )
          else
            OutlinedButton(
              onPressed: () {
                final err = context.read<CartProvider>().add(veg);
                if (err != null) SnackbarHelper.error(context, err);
              },
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(64, 34),
                foregroundColor: ShopColors.primary,
                side: const BorderSide(color: ShopColors.primaryBorder),
              ),
              child: const Text('Add'),
            ),
        ]),
      ),
    );
  }
}
