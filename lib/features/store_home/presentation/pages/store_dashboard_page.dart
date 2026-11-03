import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/routes/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

class StoreDashboardPage extends StatefulWidget {
  const StoreDashboardPage({super.key});
  @override
  State<StoreDashboardPage> createState() => _StoreDashboardPageState();
}

class _StoreDashboardPageState extends State<StoreDashboardPage> {
  int _index = 0;

  // Vegetables tab -> Step 4, Orders tab -> Step 6
  final _tabs = const <Widget>[
    _HomeTab(),
    EmptyState(
      message: 'Vegetables - coming in Step 4',
      icon: Icons.eco_outlined,
    ),
    EmptyState(
      message: 'Orders - coming in Step 6',
      icon: Icons.shopping_bag_outlined,
    ),
  ];

  @override
  Widget build(BuildContext context) => Scaffold(
    body: IndexedStack(index: _index, children: _tabs),
    bottomNavigationBar: BottomNavigationBar(
      currentIndex: _index,
      onTap: (i) => setState(() => _index = i),
      type: BottomNavigationBarType.fixed,
      backgroundColor: Colors.white,
      selectedItemColor: AppColors.primary,
      unselectedItemColor: AppColors.textSecondary,
      selectedLabelStyle: const TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w700,
      ),
      unselectedLabelStyle: const TextStyle(fontSize: 11),
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home_outlined),
          activeIcon: Icon(Icons.home),
          label: 'Home',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.eco_outlined),
          activeIcon: Icon(Icons.eco),
          label: 'Vegetables',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.shopping_bag_outlined),
          activeIcon: Icon(Icons.shopping_bag),
          label: 'Orders',
        ),
      ],
    ),
  );
}

class _HomeTab extends StatelessWidget {
  const _HomeTab();

  @override
  Widget build(BuildContext context) {
    final name = context.watch<AuthProvider>().user?.name ?? 'Store';
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
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          name,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 2),
                        const Text(
                          'Fresh Vegetables Store',
                          style: TextStyle(color: Colors.white70, fontSize: 11),
                        ),
                      ],
                    ),
                  ),
                  _HeaderIcon(
                    Icons.menu,
                    () => Navigator.pushNamed(context, AppRoutes.menu),
                  ),
                  const SizedBox(width: 8),
                  _HeaderIcon(
                    Icons.person_outline,
                    () => Navigator.pushNamed(context, AppRoutes.profile),
                  ),
                ],
              ),
            ),
          ),
        ),
        const Expanded(
          child: EmptyState(
            message: 'Dashboard stats & recent orders - coming in Step 6',
            icon: Icons.dashboard_outlined,
          ),
        ),
      ],
    );
  }
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
