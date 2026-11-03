import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/error_state.dart';
import '../../../../core/widgets/loading_indicator.dart';
import '../../domain/entities/order_entity.dart';
import '../providers/order_provider.dart';
import '../widgets/order_card.dart';
import 'store_order_detail_page.dart';

/// Store > Orders tab.
class StoreOrderListPage extends StatefulWidget {
  const StoreOrderListPage({super.key});
  @override
  State<StoreOrderListPage> createState() => _StoreOrderListPageState();
}

class _StoreOrderListPageState extends State<StoreOrderListPage> {
  static const _all = 'All';
  late final List<String> _tabs = [_all, ...AppConstants.orderStatuses];
  String _tab = _all;

  @override
  Widget build(BuildContext context) {
    final p = context.watch<OrderProvider>();
    final list = _tab == _all ? p.orders : p.byStatus(_tab);

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            SizedBox(
              height: 56,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                itemCount: _tabs.length,
                separatorBuilder: (_, _) => const SizedBox(width: 10),
                itemBuilder: (_, i) {
                  final s = _tabs[i];
                  final selected = s == _tab;
                  return GestureDetector(
                    onTap: () => setState(() => _tab = s),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: AppColors.surfaceAlt,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                            color: selected ? AppColors.primary : AppColors.border),
                      ),
                      child: Text(s,
                          style: TextStyle(
                              fontSize: 13,
                              fontWeight: selected ? FontWeight.w700 : FontWeight.w400)),
                    ),
                  );
                },
              ),
            ),
            Expanded(child: _body(p, list)),
          ],
        ),
      ),
    );
  }

  Widget _body(OrderProvider p, List<OrderEntity> list) {
    if (p.isLoading) return const LoadingIndicator();
    if (p.error != null) {
      return ErrorState(message: p.error!, onRetry: () => p.retry('all'));
    }
    if (list.isEmpty) {
      return EmptyState(
          message: _tab == _all
              ? 'No orders yet'
              : 'No ${_tab.toLowerCase()} orders',
          icon: Icons.shopping_bag_outlined);
    }
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: list.length,
      separatorBuilder: (_, _) => const SizedBox(height: 12),
      itemBuilder: (_, i) => OrderCard(
        order: list[i],
        index: i + 1,
        showStatus: _tab == _all,
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => StoreOrderDetailPage(orderId: list[i].id)),
        ),
      ),
    );
  }
}
