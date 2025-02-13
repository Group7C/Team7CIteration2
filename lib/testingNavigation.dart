import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class NavigationPage extends StatelessWidget {
  const NavigationPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Testing Navigation')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            NavigationButton(route: '/login', label: 'Go to Login'),
            NavigationButton(route: '/join', label: 'Go to Join Project'),
            // Note: '/userProfile/profile' route isn't defined in main.dart
            // If you want to keep this button, add route in main.dart 
          ],
        ),
      ),
    );
  }
}

class NavigationButton extends StatelessWidget {
  final String route;
  final String label;

  const NavigationButton({super.key, required this.route, required this.label});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: ElevatedButton(
        onPressed: () {
          Navigator.pushNamed(context, route);
        },
        child: Text(label),
      ),
    );
  }
}