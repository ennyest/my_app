import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/theme/app_theme.dart';
import 'core/services/auth_service.dart';
import 'core/services/theme_service.dart';
import 'core/services/admin_service.dart';
import 'core/services/admin_view_service.dart';
import 'core/services/gallery_service.dart';
import 'features/auth/screens/splash_screen.dart';
import 'features/auth/screens/auth_wrapper.dart';

class HairStyleApp extends StatelessWidget {
  const HairStyleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthService()),
        ChangeNotifierProvider(create: (_) => ThemeService()),
        ChangeNotifierProvider(create: (_) => AdminService()),
        ChangeNotifierProvider(create: (_) => AdminViewService()),
        ChangeNotifierProvider(create: (_) => GalleryService()),
      ],
      child: Consumer<ThemeService>(
        builder: (context, themeService, child) {
          return MaterialApp(
            title: 'HairStyle AI',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: themeService.themeMode,
            home: const SplashScreen(),
            routes: {
              '/auth': (context) => const AuthWrapper(),
            },
            builder: (context, widget) {
              // Handle global errors
              ErrorWidget.builder = (FlutterErrorDetails errorDetails) {
                return Scaffold(
                  body: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.error, size: 64, color: Colors.red),
                        const SizedBox(height: 16),
                        const Text('Something went wrong'),
                        const SizedBox(height: 8),
                        Text(
                          errorDetails.exception.toString(),
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                );
              };
              return widget!;
            },
          );
        },
      ),
    );
  }
}
