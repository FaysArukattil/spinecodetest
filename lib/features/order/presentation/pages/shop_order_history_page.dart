import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/shop_theme.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/error_state.dart';
import '../../../../core/widgets/loading_indicator.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../providers/order_provider.dart';
import '../widgets/order_card.dart';
import 'shop_order_detail_page.dart';

/// Shop "My Orders" tab: history with a status filter.
class ShopOrderHistoryPage extends StatefulWidget {
  const ShopOrderHistoryPage({super.key});
  @override
  State<ShopOrderHistoryPage> createState() => _ShopOrderHistoryPageState();
}

class _ShopOrderHistoryPageState extends State<ShopOrderHistoryPage> {
  static const _all = 'All';
  String _filter = _all;

  @override
  Widget build(BuildContext context) {
    final p = context.watch<OrderProvider>();
    final shopId = context.read<AuthProvider>().user?.id ?? '';
    final list = _filter == _all
        ? p.orders
        : p.orders.where((o) => o.status == _filter).toList();

    return Column(children: [
      SizedBox(
        height: 52,
        child: ListView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          children: [
            for (final s in [_all, ...AppConstants.orderStatuses])
              Padding(
                padding: const EdgeInsets.only(right: 8),
                child: ChoiceChip(
                  label: Text(s, style: const TextStyle(fontSize: 12)),
                  selected: _filter == s,
                  onSelected: (_) => setState(() => _filter = s),
                  selectedColor: ShopColors.primaryLight,
                  side: BorderSide(
                    color: _filter == s ? ShopColors.primary : AppColors.border,
                  ),
                  showCheckmark: false,
                  visualDensity: VisualDensity.compact,
                ),
              ),
          ],
        ),
      ),
      Expanded(
        child: p.isLoading
            ? const LoadingIndicator()
            : p.error != null
                ? ErrorState(message: p.error!, onRetry: () => p.retry(shopId))
                : list.isEmpty
                    ? EmptyState(
                        message: _filter == _all
                            ? 'You have not placed any orders yet.'
                            : 'No $_filter orders.',
                        icon: Icons.receipt_long_outlined,
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
                        itemCount: list.length,
                        separatorBuilder: (_, _) => const SizedBox(height: 10),
                        itemBuilder: (context, i) => OrderCard(
                          order: list[i],
                          index: i + 1,
                          showShopName: false,
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  ShopOrderDetailPage(orderId: list[i].id),
                            ),
                          ),
                        ),
                      ),
      ),
    ]);
  }
}
