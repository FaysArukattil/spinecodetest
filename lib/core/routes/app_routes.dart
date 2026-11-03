import '../../features/auth/domain/entities/user_entity.dart';

class AppRoutes {
  AppRoutes._();
  static const splash = '/';
  static const login = '/login';
  static const storeHome = '/store';
  static const shopHome = '/shop';
  static const profile = '/profile';
  static const menu = '/menu';

  static String homeFor(UserEntity u) => u.isStore ? storeHome : shopHome;
}
