import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/routes/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/error_state.dart';
import '../../../../core/widgets/loading_indicator.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../order/presentation/pages/store_order_detail_page.dart';
import '../../../order/presentation/pages/store_order_list_page.dart';
import '../../../order/presentation/providers/order_provider.dart';
import '../../../order/presentation/widgets/order_card.dart';
import '../../../shop/presentation/pages/shop_list_page.dart';
import '../../../shop/presentation/providers/shop_provider.dart';
import '../../../vegetable/presentation/pages/vegetable_list_page.dart';
import '../../../vegetable/presentation/providers/vegetable_provider.dart';

class StoreDashboardPage extends StatefulWidget {
  const StoreDashboardPage({super.key});
  @override
  State<StoreDashboardPage> createState() => _StoreDashboardPageState();
}

class _StoreDashboardPageState extends State<StoreDashboardPage> {
  int _index = 0;

  @override
  void initState() {
    super.initState();
    // start realtime listeners once the store is logged in
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<VegetableProvider>().start();
      context.read<ShopProvider>().start();
      context.read<OrderProvider>().startAll();
    });
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        body: IndexedStack(
          index: _index,
          children: [
            _HomeTab(
              onViewAll: () => setState(() => _index = 2),
              onNavigateVegetables: () => setState(() => _index = 1),
              onOpenShops: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ShopListPage()),
              ),
            ),
            const VegetableListPage(),
            const StoreOrderListPage(),
          ],
        ),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _index,
          onTap: (i) => setState(() => _index = i),
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.white,
          selectedItemColor: AppColors.primary,
          unselectedItemColor: AppColors.textSecondary,
          selectedLabelStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700),
          unselectedLabelStyle: const TextStyle(fontSize: 11),
          items: const [
            BottomNavigationBarItem(
                icon: Icon(Icons.home_outlined), activeIcon: Icon(Icons.home), label: 'Home'),
            BottomNavigationBarItem(
                icon: Icon(Icons.eco_outlined), activeIcon: Icon(Icons.eco), label: 'Vegetables'),
            BottomNavigationBarItem(
                icon: Icon(Icons.shopping_bag_outlined),
                activeIcon: Icon(Icons.shopping_bag),
                label: 'Orders'),
          ],
        ),
      );
}

class _HomeTab extends StatelessWidget {
  final VoidCallback onViewAll;
  final VoidCallback onNavigateVegetables;
  final VoidCallback onOpenShops;
  const _HomeTab({
    required this.onViewAll,
    required this.onNavigateVegetables,
    required this.onOpenShops,
  });

  @override
  Widget build(BuildContext context) {
    final name = context.watch<AuthProvider>().user?.name ?? 'Store';
    final orders = context.watch<OrderProvider>();
    final vegs = context.watch<VegetableProvider>();
    final shops = context.watch<ShopProvider>();
    final recent = orders.orders.take(5).toList();

    return Column(
      children: [
        Container(
          width: double.infinity,
          color: AppColors.primary,
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          child: SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.only(top: 12),
              child: Row(children: [
                Expanded(
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(name,
                        style: const TextStyle(
                            color: Colors.white, fontSize: 18, fontWeight: FontWeight.w700)),
                    const SizedBox(height: 2),
                    const Text('Fresh Vegetables Store',
                        style: TextStyle(color: Colors.white70, fontSize: 11)),
                  ]),
                ),
                _HeaderIcon(Icons.menu, () => Navigator.pushNamed(context, AppRoutes.menu)),
                const SizedBox(width: 8),
                _HeaderIcon(Icons.person_outline,
                    () => Navigator.pushNamed(context, AppRoutes.profile)),
              ]),
            ),
          ),
        ),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Row(children: [
                _StatCard('Scheduled', orders.pendingCount, AppColors.statOrange),
                const SizedBox(width: 10),
                _StatCard('Order', orders.orders.length, AppColors.statYellow),
                const SizedBox(width: 10),
                _StatCard('Completed', orders.completedCount, AppColors.statGreen),
              ]),
              const SizedBox(height: 14),
              Row(children: [
                Expanded(
                  child: InkWell(
                    onTap: onNavigateVegetables,
                    borderRadius: BorderRadius.circular(10),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceAlt,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Row(children: [
                        const Icon(Icons.eco_outlined, color: AppColors.success, size: 24),
                        const SizedBox(width: 10),
                        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Text('${vegs.items.length} Vegetables',
                              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
                          Text('${vegs.available.length} available',
                              style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                        ]),
                      ]),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: InkWell(
                    onTap: onOpenShops,
                    borderRadius: BorderRadius.circular(10),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceAlt,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Row(children: [
                        const Icon(Icons.storefront_outlined, color: AppColors.accent, size: 24),
                        const SizedBox(width: 10),
                        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Text('${shops.shops.length} Shops',
                              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
                          Text('${shops.shops.where((s) => s.isActive).length} active',
                              style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                        ]),
                      ]),
                    ),
                  ),
                ),
              ]),
              const SizedBox(height: 18),
              Row(children: [
                const Text('Orders', style: AppTextStyles.h2),
                const Spacer(),
                GestureDetector(
                  onTap: onViewAll,
                  child: const Text('View All',
                      style: TextStyle(color: AppColors.accent, fontSize: 12)),
                ),
              ]),
              const SizedBox(height: 12),
              if (orders.isLoading)
                const SizedBox(height: 200, child: LoadingIndicator())
              else if (orders.error != null)
                SizedBox(
                  height: 240,
                  child: ErrorState(
                      message: orders.error!, onRetry: () => orders.retry('all')),
                )
              else if (recent.isEmpty)
                const SizedBox(
                  height: 240,
                  child: EmptyState(
                      message: 'No orders yet', icon: Icons.shopping_bag_outlined),
                )
              else
                for (var i = 0; i < recent.length; i++)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: OrderCard(
                      order: recent[i],
                      index: i + 1,
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => StoreOrderDetailPage(orderId: recent[i].id),
                        ),
                      ),
                    ),
                  ),
            ],
          ),
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final int value;
  final Color color;
  const _StatCard(this.label, this.value, this.color);

  @override
  Widget build(BuildContext context) => Expanded(
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(10)),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(label, style: const TextStyle(color: Colors.white, fontSize: 12)),
            const SizedBox(height: 4),
            Text('$value',
                style: const TextStyle(
                    color: Colors.white, fontSize: 26, fontWeight: FontWeight.w700)),
          ]),
        ),
      );
}

class _HeaderIcon extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _HeaderIcon(this.icon, this.onTap);

  @override
  Widget build(BuildContext context) => InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: CircleAvatar(
          radius: 18,
          backgroundColor: Colors.white24,
          child: Icon(icon, color: Colors.white, size: 20),
        ),
      );
}
