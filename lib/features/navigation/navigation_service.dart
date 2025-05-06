import 'package:flutter/material.dart';

/// Centralised navigation manager [handles routing without needing context]
class NavigationService {
  // Singleton pattern to ensure single navigation instance
  static final NavigationService _instance = NavigationService._internal();
  
  // Factory gives same instance everywhere [prevents nav conflicts]
  factory NavigationService() => _instance;
  
  // Private constructor for singleton pattern
  NavigationService._internal();

  // Global nav key [allows navigation outside of widget tree]
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  // Pushes named route onto stack [standard navigation]
  Future<dynamic> navigateTo(String routeName, {Object? arguments}) {
    return navigatorKey.currentState!.pushNamed(routeName, arguments: arguments);
  }

  // Clear stack and navigate [useful for login/logout flows]
  Future<dynamic> navigateToAndRemoveUntil(String routeName, {Object? arguments}) {
    return navigatorKey.currentState!.pushNamedAndRemoveUntil(
      routeName,
      (Route<dynamic> route) => false,
      arguments: arguments,
    );
  }

  // Pops current route [go back one screen]
  void goBack() {
    navigatorKey.currentState!.pop();
  }
}
