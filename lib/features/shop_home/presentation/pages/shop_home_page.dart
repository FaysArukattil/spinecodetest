import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/routes/app_routes.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

class ShopHomePage extends StatelessWidget {
  const ShopHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final name = context.watch<AuthProvider>().user?.name ?? 'Shop';
    return Scaffold(
      appBar: AppBar(
        title: Text(name, style: const TextStyle(fontSize: 16)),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_outline),
            onPressed: () => Navigator.pushNamed(context, AppRoutes.profile),
          ),
        ],
      ),
      body: const EmptyState(
        message: 'Shop module - coming in Steps 7-8',
        icon: Icons.storefront_outlined,
      ),
    );
  }
}
