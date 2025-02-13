import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:postgres/postgres.dart';
import 'providers/theme_provider.dart';
import './login/login.dart';
import './join/join.dart';
// import './home/home.dart';
import './home/home_screen.dart';
import 'package:sevenc_iteration_two/testingNavigation.dart';
// import 'package:sevenc_iteration_two/userProfile/profile.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (context) => ThemeProvider(), // Provide the theme provider
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return MaterialApp(
      theme: themeProvider.currentTheme,  // Set theme based on provider
      initialRoute: "/home",
      routes: {
        "/home": (context) => const Home(),
        "/navigation": (context) => const NavigationPage(),
        "/login": (context) => const LoginScreen(),
        "/join": (context) => const JoinProject(),
        
      },
    );
  }
}
