import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/routes/app_routes.dart';
import '../../../../core/widgets/app_logo.dart';
import '../providers/auth_provider.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});
  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _start());
  }

  Future<void> _start() async {
    final auth = context.read<AuthProvider>();
    await Future.wait([
      auth.checkSession(),
      Future.delayed(const Duration(milliseconds: 1500)),
    ]);
    if (!mounted) return;
    final user = auth.user;
    Navigator.pushReplacementNamed(
      context,
      user != null ? AppRoutes.homeFor(user) : AppRoutes.login,
    );
  }

  @override
  Widget build(BuildContext context) =>
      const Scaffold(body: Center(child: AppLogo()));
}
