import 'package:flutter/material.dart';

import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/pages/profile_page.dart';
import '../../features/auth/presentation/pages/splash_page.dart';
import '../../features/shop_home/presentation/pages/shop_home_page.dart';
import '../../features/store_home/presentation/pages/menu_page.dart';
import '../../features/store_home/presentation/pages/store_dashboard_page.dart';
import 'app_routes.dart';

class RouteGenerator {
  RouteGenerator._();

  static Route<dynamic> generate(RouteSettings s) {
    switch (s.name) {
      case AppRoutes.login:
        return _page(const LoginPage());
      case AppRoutes.storeHome:
        return _page(const StoreDashboardPage());
      case AppRoutes.shopHome:
        return _page(const ShopHomePage());
      case AppRoutes.profile:
        return _page(const ProfilePage());
      case AppRoutes.menu:
        return _page(const MenuPage());
      case AppRoutes.splash:
      default:
        return _page(const SplashPage());
    }
  }

  static MaterialPageRoute _page(Widget w) =>
      MaterialPageRoute(builder: (_) => w);
}
