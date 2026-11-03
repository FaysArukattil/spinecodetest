import 'package:flutter/material.dart';
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

  @override
  Widget build(BuildContext context) {
    final p = context.watch<VegetableProvider>();
    final q = _query.trim().toLowerCase();
    final list = p.items.where((v) => v.name.toLowerCase().contains(q)).toList();

    return Column(children: [
      Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
        child: TextField(
          onChanged: (v) => setState(() => _query = v),
          decoration: const InputDecoration(
            hintText: 'Search...',
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
