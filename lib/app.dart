import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'core/constants/app_constants.dart';
import 'core/routes/app_routes.dart';
import 'core/routes/route_generator.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/data/datasources/auth_local_datasource.dart';
import 'features/auth/data/datasources/auth_remote_datasource.dart';
import 'features/auth/data/repositories/auth_repository_impl.dart';
import 'features/auth/domain/usecases/demo_login_with_phone_usecase.dart';
import 'features/auth/domain/usecases/get_session_usecase.dart';
import 'features/auth/domain/usecases/login_usecase.dart';
import 'features/auth/domain/usecases/login_with_phone_usecase.dart';
import 'features/auth/domain/usecases/logout_usecase.dart';
import 'features/auth/domain/usecases/verify_phone_usecase.dart';
import 'features/auth/presentation/providers/auth_provider.dart';
import 'features/cart/presentation/providers/cart_provider.dart';
import 'features/order/data/datasources/order_remote_datasource.dart';
import 'features/order/data/repositories/order_repository_impl.dart';
import 'features/order/domain/usecases/cancel_order_usecase.dart';
import 'features/order/domain/usecases/get_orders_usecase.dart';
import 'features/order/domain/usecases/get_shop_orders_usecase.dart';
import 'features/order/domain/usecases/place_order_usecase.dart';
import 'features/order/domain/usecases/update_order_items_usecase.dart';
import 'features/order/domain/usecases/update_order_status_usecase.dart';
import 'features/order/presentation/providers/order_provider.dart';
import 'features/shop/data/datasources/shop_remote_datasource.dart';
import 'features/shop/data/repositories/shop_repository_impl.dart';
import 'features/shop/domain/usecases/add_shop_usecase.dart';
import 'features/shop/domain/usecases/delete_shop_usecase.dart';
import 'features/shop/domain/usecases/get_shops_usecase.dart';
import 'features/shop/domain/usecases/toggle_shop_status_usecase.dart';
import 'features/shop/domain/usecases/update_shop_usecase.dart';
import 'features/shop/presentation/providers/shop_provider.dart';
import 'features/staff/data/datasources/staff_remote_datasource.dart';
import 'features/staff/data/repositories/staff_repository_impl.dart';
import 'features/staff/domain/usecases/add_staff_usecase.dart';
import 'features/staff/domain/usecases/delete_staff_usecase.dart';
import 'features/staff/domain/usecases/get_staff_usecase.dart';
import 'features/staff/domain/usecases/update_staff_usecase.dart';
import 'features/staff/presentation/providers/staff_provider.dart';
import 'features/vegetable/data/datasources/vegetable_remote_datasource.dart';
import 'features/vegetable/data/repositories/vegetable_repository_impl.dart';
import 'features/vegetable/domain/usecases/add_vegetable_usecase.dart';
import 'features/vegetable/domain/usecases/delete_vegetable_usecase.dart';
import 'features/vegetable/domain/usecases/get_vegetables_usecase.dart';
import 'features/vegetable/domain/usecases/update_vegetable_usecase.dart';
import 'features/vegetable/presentation/providers/vegetable_provider.dart';

class MyApp extends StatelessWidget {
  final SharedPreferences prefs;
  const MyApp({super.key, required this.prefs});

  @override
  Widget build(BuildContext context) {
    // --- dependency wiring (data -> domain -> presentation) ---
    final authRepo = AuthRepositoryImpl(
      remote: AuthRemoteDataSource(),
      local: AuthLocalDataSource(prefs),
    );
    final vegRepo = VegetableRepositoryImpl(VegetableRemoteDataSource());
    final shopRepo = ShopRepositoryImpl(ShopRemoteDataSource());
    final staffRepo = StaffRepositoryImpl(StaffRemoteDataSource());
    final orderRepo = OrderRepositoryImpl(OrderRemoteDataSource());

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => AuthProvider(
            login: LoginUseCase(authRepo),
            logout: LogoutUseCase(authRepo),
            getSession: GetSessionUseCase(authRepo),
            verifyPhone: VerifyPhoneUseCase(authRepo),
            loginWithPhone: LoginWithPhoneUseCase(authRepo),
            demoLoginWithPhone: DemoLoginWithPhoneUseCase(authRepo),
          ), // session is checked by SplashPage
        ),

        // The proxies below stop each Firestore listener when the user logs out.
        ChangeNotifierProxyProvider<AuthProvider, VegetableProvider>(
          create: (_) => VegetableProvider(
            getVegetables: GetVegetablesUseCase(vegRepo),
            addVegetable: AddVegetableUseCase(vegRepo),
            updateVegetable: UpdateVegetableUseCase(vegRepo),
            deleteVegetable: DeleteVegetableUseCase(vegRepo),
          ),
          update: (_, auth, previous) {
            if (auth.status != AuthStatus.authenticated) previous!.stop();
            return previous!;
          },
        ),
        ChangeNotifierProxyProvider<AuthProvider, ShopProvider>(
          create: (_) => ShopProvider(
            getShops: GetShopsUseCase(shopRepo),
            addShop: AddShopUseCase(shopRepo),
            updateShop: UpdateShopUseCase(shopRepo),
            deleteShop: DeleteShopUseCase(shopRepo),
            toggleStatus: ToggleShopStatusUseCase(shopRepo),
          ),
          update: (_, auth, previous) {
            if (auth.status != AuthStatus.authenticated) previous!.stop();
            return previous!;
          },
        ),
        ChangeNotifierProxyProvider<AuthProvider, StaffProvider>(
          create: (_) => StaffProvider(
            getStaff: GetStaffUseCase(staffRepo),
            addStaff: AddStaffUseCase(staffRepo),
            updateStaff: UpdateStaffUseCase(staffRepo),
            deleteStaff: DeleteStaffUseCase(staffRepo),
          ),
          update: (_, auth, previous) {
            if (auth.status != AuthStatus.authenticated) previous!.stop();
            return previous!;
          },
        ),
        // The cart is emptied on logout so the next user starts clean.
        ChangeNotifierProxyProvider<AuthProvider, CartProvider>(
          create: (_) => CartProvider(),
          update: (_, auth, previous) {
            if (auth.status != AuthStatus.authenticated) previous!.reset();
            return previous!;
          },
        ),
        ChangeNotifierProxyProvider<AuthProvider, OrderProvider>(
          create: (_) => OrderProvider(
            getOrders: GetOrdersUseCase(orderRepo),
            getShopOrders: GetShopOrdersUseCase(orderRepo),
            placeOrder: PlaceOrderUseCase(orderRepo),
            updateStatus: UpdateOrderStatusUseCase(orderRepo),
            updateItems: UpdateOrderItemsUseCase(orderRepo),
            cancelOrder: CancelOrderUseCase(orderRepo),
          ),
          update: (_, auth, previous) {
            if (auth.status != AuthStatus.authenticated) previous!.stop();
            return previous!;
          },
        ),
      ],
      child: MaterialApp(
        title: AppConstants.appName,
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        initialRoute: AppRoutes.splash,
        onGenerateRoute: RouteGenerator.generate,
      ),
    );
  }
}
