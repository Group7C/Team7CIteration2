import "package:flutter/material.dart";
import 'package:provider/provider.dart';
// Removed import for testingNavigation.dart that was moved to redundant
import 'package:postgres/postgres.dart';
import 'package:sevenc_iteration_two/usser/usserObject.dart';
import './login/login.dart';
import './join/join.dart';
import './features/home/home_feature.dart';
import './features/navigation/main_navigation.dart';
import './features/navigation/navigation_service.dart';
import 'providers/theme_provider.dart';
import 'providers/tasks_provider.dart';
import 'usser/usserProfilePage.dart';
import 'settings_page.dart';
import 'join/project.dart';

void main() {
  runApp(
      MultiProvider(
        providers: [
          // creating blank initial providers
          ChangeNotifierProvider(create: (context) => Usser("","","","Light",null,0,{},)),
          ChangeNotifierProvider(create: (context) => Project("","",null)),
          ChangeNotifierProvider(create: (context) => ThemeProvider()),
          ChangeNotifierProvider(create: (context) => TaskProvider()),
        ],
        child: const MyApp(),
      )
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return MaterialApp(
      navigatorKey: NavigationService().navigatorKey,  // Add navigator key
      theme: themeProvider.currentTheme, // Set theme based on provider
      initialRoute: "/login",
      routes: {
        "/home": (context) => const MainNavigation(),  // Use MainNavigation
        // Navigation route removed as NavigationPage was moved to redundant
        // "/navigation": (context) => const NavigationPage(),
        "/login": (context) => const LoginScreen(),
        "/join": (context) => const JoinProject(),
        "/settings": (context) => const SettingsPage(),
        "/profile": (context) => UsserProfile(usser: Provider.of<Usser>(context)),
      },
    );
  }
}
