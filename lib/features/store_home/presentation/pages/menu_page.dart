import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../reports/presentation/pages/sales_report_page.dart';
import '../../../shop/presentation/pages/shop_list_page.dart';
import '../../../staff/presentation/pages/staff_list_page.dart';

class MenuPage extends StatelessWidget {
  const MenuPage({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('Menu', style: TextStyle(fontSize: 16))),
        body: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _MenuTile(
              icon: Icons.people_outline,
              title: 'Staff Management',
              subtitle: 'Add, view, and manage staff members',
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const StaffListPage()),
              ),
            ),
            const SizedBox(height: 12),
            _MenuTile(
              icon: Icons.storefront_outlined,
              title: 'Shops',
              subtitle: 'Add, view, and manage shops',
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ShopListPage()),
              ),
            ),
            const SizedBox(height: 12),
            _MenuTile(
              icon: Icons.bar_chart_outlined,
              title: 'Sales Reports',
              subtitle: 'Filter orders by shop, date, and metrics',
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SalesReportPage()),
              ),
            ),
          ],
        ),
      );
}

class _MenuTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  const _MenuTile(
      {required this.icon, required this.title, required this.subtitle, required this.onTap});

  @override
  Widget build(BuildContext context) => InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.surfaceAlt,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(children: [
            Icon(icon),
            const SizedBox(width: 12),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(title, style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w600)),
                Text(subtitle, style: AppTextStyles.caption),
              ]),
            ),
            const Icon(Icons.chevron_right, size: 20),
          ]),
        ),
      );
}
