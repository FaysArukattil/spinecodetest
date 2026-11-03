import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'core/constants/app_constants.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/data/datasources/auth_local_datasource.dart';
import 'features/auth/data/datasources/auth_remote_datasource.dart';
import 'features/auth/data/repositories/auth_repository_impl.dart';
import 'features/auth/domain/usecases/get_session_usecase.dart';
import 'features/auth/domain/usecases/login_usecase.dart';
import 'features/auth/domain/usecases/logout_usecase.dart';
import 'features/auth/presentation/providers/auth_provider.dart';

class MyApp extends StatelessWidget {
  final SharedPreferences prefs;
  const MyApp({super.key, required this.prefs});

  @override
  Widget build(BuildContext context) {
    final authRepo = AuthRepositoryImpl(
      remote: AuthRemoteDataSource(),
      local: AuthLocalDataSource(prefs),
    );

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => AuthProvider(
            login: LoginUseCase(authRepo),
            logout: LogoutUseCase(authRepo),
            getSession: GetSessionUseCase(authRepo),
          )..checkSession(),
        ),
        // more providers get added here in later steps
      ],
      child: MaterialApp(
        title: AppConstants.appName,
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        home: const _TempHome(), // replaced by SplashPage in Step 3
      ),
    );
  }
}

/// Temporary screen just to verify Firebase + session work.
class _TempHome extends StatelessWidget {
  const _TempHome();

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    return Scaffold(
      body: Center(
        child: Text(
          'Session: ${auth.status.name}\nUser: ${auth.user?.email ?? '-'}',
        ),
      ),
    );
  }
}
