import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
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
  bool _showScheduled = false;
  String? _selectedStore;
  DateTimeRange? _dateRange;

  void _pickStore() {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Filter by Store', style: TextStyle(fontSize: 16)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text('All Stores'),
              selected: _selectedStore == null,
              onTap: () {
                setState(() => _selectedStore = null);
                Navigator.pop(ctx);
              },
            ),
            ListTile(
              title: const Text('Fresh Vegetables Store'),
              subtitle: const Text('Main Central Wholesale Depot'),
              selected: _selectedStore == 'Fresh Vegetables Store',
              onTap: () {
                setState(() => _selectedStore = 'Fresh Vegetables Store');
                Navigator.pop(ctx);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickDateRange() async {
    final range = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2024),
      lastDate: DateTime(2030),
      initialDateRange: _dateRange,
    );
    if (range != null) {
      setState(() => _dateRange = range);
    }
  }

  @override
  Widget build(BuildContext context) {
    final p = context.watch<OrderProvider>();
    final shopId = context.read<AuthProvider>().user?.id ?? '';
    var baseList = _showScheduled
        ? p.orders.where((o) => o.status == AppConstants.orderPending).toList()
        : p.orders;

    if (_filter != _all) {
      baseList = baseList.where((o) => o.status == _filter).toList();
    }
    if (_dateRange != null) {
      baseList = baseList.where((o) {
        final d = o.createdAt;
        return d.isAfter(_dateRange!.start.subtract(const Duration(seconds: 1))) &&
            d.isBefore(_dateRange!.end.add(const Duration(days: 1)));
      }).toList();
    }

    final list = baseList;

    return Column(children: [
      // Figma Segmented Control: Order N / Scheduled N
      Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
        child: Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: ShopColors.primaryLight,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _showScheduled = false),
                  child: Container(
                    height: 36,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: !_showScheduled ? ShopColors.primary : Colors.transparent,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'Orders (${p.orders.length})',
                      style: TextStyle(
                        color: !_showScheduled ? Colors.white : ShopColors.primary,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _showScheduled = true),
                  child: Container(
                    height: 36,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: _showScheduled ? ShopColors.primary : Colors.transparent,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'Scheduled (${p.byStatus(AppConstants.orderPending).length})',
                      style: TextStyle(
                        color: _showScheduled ? Colors.white : ShopColors.primary,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      // Figma: Filter by Store & Filter by Date
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        child: Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                icon: const Icon(Icons.storefront_outlined, size: 14),
                label: Text(
                  _selectedStore ?? 'Filter by Store',
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 11),
                ),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  minimumSize: const Size(0, 36),
                ),
                onPressed: _pickStore,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: OutlinedButton.icon(
                icon: const Icon(Icons.calendar_today_outlined, size: 14),
                label: Text(
                  _dateRange != null
                      ? '${DateFormat('dd MMM').format(_dateRange!.start)} - ${DateFormat('dd MMM').format(_dateRange!.end)}'
                      : 'Filter by Date',
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 11),
                ),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  minimumSize: const Size(0, 36),
                ),
                onPressed: _pickDateRange,
              ),
            ),
            if (_selectedStore != null || _dateRange != null)
              IconButton(
                icon: const Icon(Icons.clear, size: 18),
                tooltip: 'Clear filters',
                onPressed: () => setState(() {
                  _selectedStore = null;
                  _dateRange = null;
                }),
              ),
          ],
        ),
      ),
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
