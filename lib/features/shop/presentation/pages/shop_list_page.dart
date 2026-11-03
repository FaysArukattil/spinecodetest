import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/snackbar_helper.dart';
import '../../../../core/widgets/confirm_dialog.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/error_state.dart';
import '../../../../core/widgets/loading_indicator.dart';
import '../../domain/entities/shop_entity.dart';
import '../providers/shop_provider.dart';
import '../widgets/shop_card.dart';
import 'add_edit_shop_page.dart';

class ShopListPage extends StatelessWidget {
  const ShopListPage({super.key});

  void _openForm(BuildContext context, [ShopEntity? shop]) => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => AddEditShopPage(shop: shop)),
      );

  Future<void> _toggle(BuildContext context, ShopEntity shop, bool activate) async {
    final p = context.read<ShopProvider>();
    final yes = await ConfirmDialog.show(
      context,
      title: activate ? 'Activate Shop' : 'Deactivate Shop',
      message: 'Are you sure you want to ${activate ? 'activate' : 'deactivate'} this Shop?',
      confirmLabel: 'Yes',
      cancelLabel: 'No',
      color: activate ? AppColors.success : AppColors.error,
    );
    if (!yes || !context.mounted) return;
    final err = await p.setActive(shop, activate);
    if (err != null && context.mounted) SnackbarHelper.error(context, err);
  }

  Future<void> _delete(BuildContext context, ShopEntity shop) async {
    final p = context.read<ShopProvider>();
    final yes = await ConfirmDialog.show(
      context,
      title: 'Delete Shop',
      message: 'Are you sure you want to delete "${shop.shopName}"? The shop will no longer be able to log in.',
      confirmLabel: 'Yes, Delete',
    );
    if (!yes || !context.mounted) return;
    final err = await p.delete(shop.id);
    if (!context.mounted) return;
    err == null
        ? SnackbarHelper.success(context, 'Shop deleted')
        : SnackbarHelper.error(context, err);
  }

  @override
  Widget build(BuildContext context) {
    final p = context.watch<ShopProvider>();
    return Scaffold(
      appBar: AppBar(title: const Text('Shops', style: TextStyle(fontSize: 16))),
      body: Column(
        children: [
          Expanded(child: _body(context, p)),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
              child: CustomButton(
                label: '+ Add New Shop',
                onPressed: () => _openForm(context),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _body(BuildContext context, ShopProvider p) {
    if (p.isLoading) return const LoadingIndicator();
    if (p.error != null) {
      return ErrorState(message: p.error!, onRetry: () => p.start(force: true));
    }
    if (p.shops.isEmpty) {
      return const EmptyState(message: 'No shops added yet', icon: Icons.storefront_outlined);
    }
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: p.shops.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (_, i) {
        final shop = p.shops[i];
        return ShopCard(
          index: i + 1,
          shop: shop,
          onEdit: () => _openForm(context, shop),
          onDelete: () => _delete(context, shop),
          onToggle: (v) => _toggle(context, shop, v),
        );
      },
    );
  }
}
