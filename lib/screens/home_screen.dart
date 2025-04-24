import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import 'login_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);
    final user = authService.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await authService.logout();
              if (context.mounted) {
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                );
              }
            },
          ),
        ],
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.check_circle,
                color: Colors.green,
                size: 80.0,
              ),
              const SizedBox(height: 16),
              const Text(
                'Successfully Logged In!',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              Card(
                margin: const EdgeInsets.all(8.0),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        'User Information',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Divider(),
                      const SizedBox(height: 8),
                      Text(
                        'Username: ${user?.username ?? 'Unknown'}',
                        style: const TextStyle(fontSize: 16),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Email: ${user?.email ?? 'N/A'}',
                        style: const TextStyle(fontSize: 16),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'User ID: ${user?.id ?? 'Unknown'}',
                        style: const TextStyle(fontSize: 16),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'You have successfully connected to your AWS PostgreSQL database!',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
