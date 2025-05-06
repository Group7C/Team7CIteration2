import 'package:flutter/material.dart';
import 'package:sevenc_iteration_two/usser/usserObject.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';

class UsserProfile extends StatelessWidget {
  final Usser usser;

  const UsserProfile({Key? key, required this.usser}) : super(key: key);

  // Function to open documentation website
  Future<void> _openDocumentationSite() async {
    final Uri url = Uri.parse('https://courseworkappdocumentation.readthedocs.io/en/latest/');
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      throw Exception('Could not launch $url');
    }
  }

  // Function to handle logout
  void _handleLogout(BuildContext context) {
    // Show confirmation dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Logout'),
          content: const Text('Are you sure you want to log out?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                // Navigate to login screen (replace route as needed)
                Navigator.of(context).pop();
                Navigator.of(context).pushReplacementNamed('/login');
              },
              child: const Text('Logout', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Profile'),
        actions: [
          // Help button
          IconButton(
            icon: const Icon(Icons.help_outline),
            tooltip: 'Help Documentation',
            onPressed: _openDocumentationSite,
          ),
          // Logout button
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
            onPressed: () => _handleLogout(context),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Profile Header Section
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16.0),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      // Profile image
                      CircleAvatar(
                        radius: 60,
                        backgroundColor: theme.colorScheme.primary.withOpacity(0.2),
                        backgroundImage: usser.profilePic != null 
                            ? NetworkImage(usser.profilePic!) 
                            : null,
                        child: usser.profilePic == null 
                            ? Icon(
                                Icons.person,
                                size: 80,
                                color: theme.colorScheme.primary,
                              ) 
                            : null,
                      ),
                      const SizedBox(height: 16),
                      
                      // Username
                      Text(
                        usser.usserName,
                        style: theme.textTheme.headlineSmall,
                      ),
                      
                      // Email
                      Text(
                        usser.email,
                        style: theme.textTheme.bodyLarge,
                      ),
                    ],
                  ),
                ),
              ),
              
              // Action Buttons
              const SizedBox(height: 24),
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.0),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 24.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      // Theme Button
                      _buildCenteredButton(
                        context,
                        'Theme',
                        Icons.color_lens,
                        theme.colorScheme.secondary,
                        () {
                          // Show theme selection modal
                          showModalBottomSheet(
                            context: context,
                            builder: (context) => _buildThemeSelectionModal(context),
                          );
                        },
                      ),
                      
                      // Help & Support Button
                      _buildCenteredButton(
                        context,
                        'Help & Support',
                        Icons.help,
                        Colors.purple,
                        _openDocumentationSite,
                      ),
                      
                      // Logout Button
                      _buildCenteredButton(
                        context,
                        'Logout',
                        Icons.logout,
                        Colors.red,
                        () => _handleLogout(context),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  // Helper method to build a centered button
  Widget _buildCenteredButton(BuildContext context, String title, IconData icon, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: color,
              size: 32,
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  // Helper method to build stat cards
  Widget _buildStatCard(BuildContext context, String title, String value, IconData icon, Color color) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: color,
              size: 32,
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: color,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
  
  // Build theme selection modal
  Widget _buildThemeSelectionModal(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    
    return Container(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Select Theme',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 20),
          // Light theme option
          ListTile(
            leading: const Icon(Icons.wb_sunny),
            title: const Text('Light Theme'),
            onTap: () {
              // Set light theme
              themeProvider.setTheme(ThemeType.light);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Light theme applied')),
              );
            },
          ),
          // Dark theme option
          ListTile(
            leading: const Icon(Icons.nightlight_round),
            title: const Text('Dark Theme'),
            onTap: () {
              // Set dark theme
              themeProvider.setTheme(ThemeType.dark);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Dark theme applied')),
              );
            },
          ),
          // Custom theme option
          ListTile(
            leading: const Icon(Icons.color_lens),
            title: const Text('Custom Theme'),
            onTap: () {
              // Navigate to custom theme settings
              themeProvider.setTheme(ThemeType.custom);
              Navigator.pop(context);
              Navigator.pushNamed(context, '/settings');
            },
          ),
        ],
      ),
    );
  }
}