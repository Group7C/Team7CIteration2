import "package:flutter/material.dart";
import 'package:provider/provider.dart';
import 'package:sevenc_iteration_two/testingNavigation.dart';
import 'package:postgres/postgres.dart';
import 'package:sevenc_iteration_two/usser/usserObject.dart';
import './login/login.dart';
import './join/join.dart';
import './home/home.dart';
import 'providers/theme_provider.dart';
import 'providers/tasks_provider.dart';
import 'usser/usserProfilePage.dart';
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
      theme: themeProvider.currentTheme, // Set theme based on provider
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
