import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'providers/auth_provider.dart';
import 'providers/complaint_provider.dart';
import 'providers/appointment_provider.dart';
import 'providers/announcement_provider.dart';
import 'constants/app_theme.dart';
import 'screens/auth/login_screen.dart';
import 'screens/navigation_shell.dart';
import 'screens/splash_screen.dart'; // Use the dedicated splash screen
import 'services/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Start Firebase initialization but don't block the whole app if it takes too long
  // We'll handle the actual initialization inside the SplashScreen/Provider
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()..initializeAuth()),
        ChangeNotifierProvider(create: (_) => ComplaintProvider()),
        ChangeNotifierProvider(create: (_) => AppointmentProvider()),
        ChangeNotifierProvider(create: (_) => AnnouncementProvider()),
      ],
      child: MaterialApp(
        title: 'Barangay Portal',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        home: const AppRoot(),
      ),
    );
  }
}

class AppRoot extends StatelessWidget {
  const AppRoot({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, _) {
        print('DEBUG: AppRoot build. isLoggedIn: ${authProvider.isLoggedIn}, isLoading: ${authProvider.isLoading}');
        
        // If the provider says we're loading and we aren't logged in yet, show splash
        if (authProvider.isLoading && !authProvider.isLoggedIn) {
          return const SplashScreen();
        }

        // If we have a session, go to dashboard
        if (authProvider.isLoggedIn) {
          return const NavigationShell();
        }

        return const LoginScreen();
      },
    );
  }
}
