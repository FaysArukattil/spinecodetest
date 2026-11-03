import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/routes/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/shop_theme.dart';
import '../../../../core/utils/snackbar_helper.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../cart/presentation/pages/cart_page.dart';
import '../../../cart/presentation/providers/cart_provider.dart';
import '../../../order/presentation/pages/shop_order_history_page.dart';
import '../../../order/presentation/providers/order_provider.dart';
import '../../../vegetable/presentation/pages/shop_vegetable_list_page.dart';
import '../../../vegetable/presentation/providers/vegetable_provider.dart';

class ShopHomePage extends StatefulWidget {
  const ShopHomePage({super.key});
  @override
  State<ShopHomePage> createState() => _ShopHomePageState();
}

class _ShopHomePageState extends State<ShopHomePage> {
  int _index = 0;

  @override
  void initState() {
    super.initState();
    // start realtime listeners once the shop is logged in
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final user = context.read<AuthProvider>().user;
      context.read<VegetableProvider>().start();
      if (user != null) context.read<OrderProvider>().startForShop(user.id);
    });
  }

  void _openCart() => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const CartPage()),
      );

  void _placeOrder() {
    if (context.read<CartProvider>().isEmpty) {
      SnackbarHelper.error(context, 'Add at least one vegetable to your cart.');
      return;
    }
    _openCart();
  }

  @override
  Widget build(BuildContext context) {
    final name = context.watch<AuthProvider>().user?.name ?? 'Shop';
    final cartCount = context.watch<CartProvider>().itemCount;

    return ShopTheme(
      child: Scaffold(
        body: Column(children: [
          _Header(
            title: _index == 0 ? name : 'My Orders',
            subtitle: _index == 0 ? 'Fresh Vegetables Store' : name,
            cartCount: cartCount,
            onCart: _openCart,
          ),
          Expanded(
            child: IndexedStack(index: _index, children: [
              Column(children: [
                const Expanded(child: ShopVegetableListPage()),
                SafeArea(
                  top: false,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 4, 16, 10),
                    child: ElevatedButton.icon(
                      onPressed: _placeOrder,
                      icon: const Icon(Icons.shopping_cart_outlined, size: 18),
                      label: Text(
                        cartCount == 0
                            ? 'Place Order'
                            : 'Place Order ($cartCount item${cartCount == 1 ? '' : 's'})',
                      ),
                    ),
                  ),
                ),
              ]),
              const ShopOrderHistoryPage(),
            ]),
          ),
        ]),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _index,
          onTap: (i) => setState(() => _index = i),
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.white,
          selectedItemColor: ShopColors.primary,
          unselectedItemColor: AppColors.textSecondary,
          selectedLabelStyle:
              const TextStyle(fontSize: 11, fontWeight: FontWeight.w700),
          unselectedLabelStyle: const TextStyle(fontSize: 11),
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.eco_outlined),
              activeIcon: Icon(Icons.eco),
              label: 'Vegetables',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.receipt_long_outlined),
              activeIcon: Icon(Icons.receipt_long),
              label: 'Orders',
            ),
          ],
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  final String title;
  final String subtitle;
  final int cartCount;
  final VoidCallback onCart;
  const _Header({
    required this.title,
    required this.subtitle,
    required this.cartCount,
    required this.onCart,
  });

  @override
  Widget build(BuildContext context) => Container(
        width: double.infinity,
        color: ShopColors.primary,
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        child: SafeArea(
          bottom: false,
          child: Padding(
            padding: const EdgeInsets.only(top: 12),
            child: Row(children: [
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w700)),
                  const SizedBox(height: 2),
                  Text(subtitle,
                      style: const TextStyle(color: Colors.white70, fontSize: 11)),
                ]),
              ),
              InkWell(
                onTap: onCart,
                customBorder: const CircleBorder(),
                child: CircleAvatar(
                  radius: 18,
                  backgroundColor: Colors.white24,
                  child: Badge(
                    isLabelVisible: cartCount > 0,
                    label: Text('$cartCount'),
                    child: const Icon(Icons.shopping_cart_outlined,
                        color: Colors.white, size: 20),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              InkWell(
                onTap: () => Navigator.pushNamed(context, AppRoutes.profile),
                customBorder: const CircleBorder(),
                child: const CircleAvatar(
                  radius: 18,
                  backgroundColor: Colors.white24,
                  child: Icon(Icons.person_outline, color: Colors.white, size: 20),
                ),
              ),
            ]),
          ),
        ),
      );
}
