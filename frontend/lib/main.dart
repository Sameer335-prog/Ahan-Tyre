import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'core/theme/app_theme.dart';
import 'core/constants/env.dart';
import 'features/auth/auth_controller.dart';
import 'app/router/app_router.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Supabase
  await Supabase.initialize(
    url: Env.supabaseUrl,
    publishableKey: Env.supabaseAnonKey,
  );

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthController()),
      ],
      child: const AhsanTyreApp(),
    ),
  );
}

class AhsanTyreApp extends StatelessWidget {
  const AhsanTyreApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Read the auth controller to build the router (which listens to it)
    final authController = context.read<AuthController>();
    final router = AppRouter.createRouter(authController);

    return MaterialApp.router(
      title: 'Ahsan Tyre',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.light, // Default to light theme for business apps
      routerConfig: router,
    );
  }
}
