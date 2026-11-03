import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../order/presentation/pages/store_order_detail_page.dart';
import '../../../order/presentation/providers/order_provider.dart';
import '../../../order/presentation/widgets/order_card.dart';
import '../../../shop/domain/entities/shop_entity.dart';
import '../../../shop/presentation/providers/shop_provider.dart';

class SalesReportPage extends StatefulWidget {
  const SalesReportPage({super.key});

  @override
  State<SalesReportPage> createState() => _SalesReportPageState();
}

class _SalesReportPageState extends State<SalesReportPage> {
  String _selectedShopId = 'all';
  String _dateFilter = 'all'; // all, today, week, month, custom
  DateTimeRange? _customRange;

  bool _matchesDate(DateTime dt) {
    final now = DateTime.now();
    switch (_dateFilter) {
      case 'today':
        return dt.year == now.year && dt.month == now.month && dt.day == now.day;
      case 'week':
        final weekAgo = now.subtract(const Duration(days: 7));
        return dt.isAfter(weekAgo);
      case 'month':
        return dt.year == now.year && dt.month == now.month;
      case 'custom':
        if (_customRange == null) return true;
        return dt.isAfter(_customRange!.start.subtract(const Duration(seconds: 1))) &&
            dt.isBefore(_customRange!.end.add(const Duration(days: 1)));
      default:
        return true;
    }
  }

  void _chooseShop(List<ShopEntity> shops) {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Filter by Shop', style: TextStyle(fontSize: 16)),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView(
            shrinkWrap: true,
            children: [
              ListTile(
                title: const Text('All Shops'),
                selected: _selectedShopId == 'all',
                onTap: () {
                  setState(() => _selectedShopId = 'all');
                  Navigator.pop(ctx);
                },
              ),
              const Divider(height: 1),
              for (final s in shops)
                ListTile(
                  title: Text(s.shopName),
                  subtitle: Text(s.ownerName, style: const TextStyle(fontSize: 11)),
                  selected: _selectedShopId == s.id,
                  onTap: () {
                    setState(() => _selectedShopId = s.id);
                    Navigator.pop(ctx);
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _pickDateRange() async {
    final range = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 1)),
      initialDateRange: _customRange ??
          DateTimeRange(
            start: DateTime.now().subtract(const Duration(days: 7)),
            end: DateTime.now(),
          ),
    );
    if (range != null) {
      setState(() {
        _dateFilter = 'custom';
        _customRange = range;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final orderP = context.watch<OrderProvider>();
    final shopP = context.watch<ShopProvider>();

    final selectedShop = _selectedShopId == 'all'
        ? null
        : shopP.shops.where((s) => s.id == _selectedShopId).firstOrNull;

    final filtered = orderP.orders.where((o) {
      if (_selectedShopId != 'all' && o.shopId != _selectedShopId) return false;
      return _matchesDate(o.createdAt);
    }).toList();

    final completedOrders =
        filtered.where((o) => o.status == AppConstants.orderCompleted).toList();
    final totalRevenue =
        completedOrders.fold<double>(0.0, (sum, o) => sum + o.totalAmount);

    String dateLabel = 'All Dates';
    if (_dateFilter == 'today') dateLabel = 'Today';
    if (_dateFilter == 'week') dateLabel = 'Last 7 Days';
    if (_dateFilter == 'month') dateLabel = 'This Month';
    if (_dateFilter == 'custom' && _customRange != null) {
      final f = DateFormat('dd/MM/yy');
      dateLabel = '${f.format(_customRange!.start)} - ${f.format(_customRange!.end)}';
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Sales Reports', style: TextStyle(fontSize: 16))),
      body: Column(
        children: [
          // Filter Row (Figma: Filter by Shop & Filter by Date)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            color: AppColors.surfaceAlt,
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _chooseShop(shopP.shops),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      minimumSize: const Size(0, 38),
                    ),
                    icon: const Icon(Icons.storefront_outlined, size: 16),
                    label: Text(
                      selectedShop?.shopName ?? 'All Shops',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 12),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      showModalBottomSheet<void>(
                        context: context,
                        builder: (ctx) => SafeArea(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              ListTile(
                                title: const Text('All Dates'),
                                onTap: () {
                                  setState(() => _dateFilter = 'all');
                                  Navigator.pop(ctx);
                                },
                              ),
                              ListTile(
                                title: const Text('Today'),
                                onTap: () {
                                  setState(() => _dateFilter = 'today');
                                  Navigator.pop(ctx);
                                },
                              ),
                              ListTile(
                                title: const Text('Last 7 Days'),
                                onTap: () {
                                  setState(() => _dateFilter = 'week');
                                  Navigator.pop(ctx);
                                },
                              ),
                              ListTile(
                                title: const Text('This Month'),
                                onTap: () {
                                  setState(() => _dateFilter = 'month');
                                  Navigator.pop(ctx);
                                },
                              ),
                              ListTile(
                                title: const Text('Custom Range...'),
                                onTap: () {
                                  Navigator.pop(ctx);
                                  _pickDateRange();
                                },
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      minimumSize: const Size(0, 38),
                    ),
                    icon: const Icon(Icons.calendar_today_outlined, size: 16),
                    label: Text(
                      dateLabel,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 12),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Metrics Tiles (Figma: Total Orders & Complete Orders)
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                _ReportTile('Total Orders', '${filtered.length}', AppColors.statYellow),
                const SizedBox(width: 10),
                _ReportTile('Completed', '${completedOrders.length}', AppColors.statGreen),
                const SizedBox(width: 10),
                _ReportTile('Revenue', Formatters.money(totalRevenue), AppColors.accent),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                const Text('Report Orders', style: AppTextStyles.h2),
                const Spacer(),
                Text('${filtered.length} found', style: AppTextStyles.caption),
              ],
            ),
          ),
          const SizedBox(height: 8),

          Expanded(
            child: filtered.isEmpty
                ? const EmptyState(
                    message: 'No orders match this filter criteria.',
                    icon: Icons.receipt_long_outlined,
                  )
                : ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: filtered.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 10),
                    itemBuilder: (context, i) => OrderCard(
                      order: filtered[i],
                      index: i + 1,
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => StoreOrderDetailPage(orderId: filtered[i].id),
                        ),
                      ),
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}

class _ReportTile extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  const _ReportTile(this.label, this.value, this.color);

  @override
  Widget build(BuildContext context) => Expanded(
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(color: Colors.white, fontSize: 11),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      );
}
