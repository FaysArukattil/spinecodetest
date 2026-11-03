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

class ShopListPage extends StatefulWidget {
  final bool showAppBar;
  const ShopListPage({super.key, this.showAppBar = true});

  @override
  State<ShopListPage> createState() => _ShopListPageState();
}

class _ShopListPageState extends State<ShopListPage> {
  String _query = '';

  void _openForm([ShopEntity? shop]) => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => AddEditShopPage(shop: shop)),
      );

  Future<void> _toggle(ShopEntity shop, bool activate) async {
    final p = context.read<ShopProvider>();
    final yes = await ConfirmDialog.show(
      context,
      title: activate ? 'Activate Shop' : 'Block Shop',
      message: 'Are you sure you want to ${activate ? 'activate' : 'block'} "${shop.shopName}"?',
      confirmLabel: activate ? 'Yes, Activate' : 'Yes, Block',
      cancelLabel: 'Cancel',
      color: activate ? AppColors.success : AppColors.error,
    );
    if (!yes || !mounted) return;
    final err = await p.setActive(shop, activate);
    if (err != null && mounted) SnackbarHelper.error(context, err);
  }

  Future<void> _delete(ShopEntity shop) async {
    final p = context.read<ShopProvider>();
    final yes = await ConfirmDialog.show(
      context,
      title: 'Delete Shop',
      message: 'Are you sure you want to delete "${shop.shopName}"? The shop will no longer be able to log in.',
      confirmLabel: 'Yes, Delete',
    );
    if (!yes || !mounted) return;
    final err = await p.delete(shop.id);
    if (!mounted) return;
    err == null
        ? SnackbarHelper.success(context, 'Shop deleted')
        : SnackbarHelper.error(context, err);
  }

  @override
  Widget build(BuildContext context) {
    final p = context.watch<ShopProvider>();
    final q = _query.trim().toLowerCase();
    final list = q.isEmpty
        ? p.shops
        : p.shops.where((s) =>
            s.shopName.toLowerCase().contains(q) ||
            s.ownerName.toLowerCase().contains(q) ||
            s.phone.contains(q) ||
            s.address.toLowerCase().contains(q)).toList();

    return Scaffold(
      appBar: widget.showAppBar
          ? AppBar(title: const Text('Shops', style: TextStyle(fontSize: 16)))
          : null,
      body: SafeArea(
        top: !widget.showAppBar,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
              child: TextField(
                onChanged: (v) => setState(() => _query = v),
                decoration: const InputDecoration(
                  hintText: 'Search shops by name, phone, address...',
                  prefixIcon: Icon(Icons.search, size: 20),
                  isDense: true,
                ),
              ),
            ),
            Expanded(child: _body(p, list)),
            SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                child: CustomButton(
                  label: '+ Add New Shop',
                  onPressed: () => _openForm(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _body(ShopProvider p, List<ShopEntity> list) {
    if (p.isLoading) return const LoadingIndicator();
    if (p.error != null) {
      return ErrorState(message: p.error!, onRetry: () => p.start(force: true));
    }
    if (list.isEmpty) {
      return EmptyState(
        message: _query.isNotEmpty
            ? 'No shops match "$_query"'
            : 'No shops added yet',
        icon: Icons.storefront_outlined,
      );
    }
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: list.length,
      separatorBuilder: (_, _) => const SizedBox(height: 12),
      itemBuilder: (_, i) {
        final shop = list[i];
        return ShopCard(
          index: i + 1,
          shop: shop,
          onEdit: () => _openForm(shop),
          onDelete: () => _delete(shop),
          onToggle: (v) => _toggle(shop, v),
        );
      },
    );
  }
}
