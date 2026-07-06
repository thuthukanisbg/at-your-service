import 'package:flutter/material.dart';

import 'core/theme/app_theme.dart';
import 'core/theme/theme_mode_controller.dart';
import 'core/widgets/mobile_frame.dart';
import 'features/admin/admin_login_screen.dart';
import 'features/admin/admin_shell.dart';
import 'features/customer/customer_shell.dart';
import 'features/onboarding/splash_screen.dart';
import 'features/provider/provider_shell.dart';

class AtYourServiceApp extends StatelessWidget {
  const AtYourServiceApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: ThemeModeController.mode,
      builder: (context, themeMode, _) {
        return MaterialApp(
          title: 'At Your Service',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.light(),
          darkTheme: AppTheme.dark(),
          themeMode: themeMode,
          builder: (context, child) => MobileFrame(child: child!),
          initialRoute: SplashScreen.routeName,
          routes: {
            SplashScreen.routeName: (_) => const SplashScreen(),
            CustomerShell.routeName: (_) => const CustomerShell(),
            ProviderShell.routeName: (_) => const ProviderShell(),
            AdminShell.routeName: (_) => const AdminShell(),
            AdminLoginScreen.routeName: (_) => const AdminLoginScreen(),
          },
        );
      },
    );
  }
}
