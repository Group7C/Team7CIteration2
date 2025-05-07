import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'app_scaffold.dart';
import '../home/screens/home_screen.dart';
import '../projects/screens/projects_screen.dart';
import '../../settings_page.dart';
import '../../usser/usserProfilePage.dart';
import '../../usser/usserObject.dart';

class MainNavigation extends StatefulWidget {
  const MainNavigation({Key? key}) : super(key: key);

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _selectedIndex = 0;

  // List of screens
  final List<Widget> _screens = [
    const HomeScreen(),
    const ProjectsScreen(),
    const Center(child: Text('Profile')), // Placeholder that will be replaced
  ];
  
  @override
  void initState() {
    super.initState();
    
    // Update the profile screen after the widget is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        final usser = Provider.of<Usser>(context, listen: false);
        if (_selectedIndex == 2) {
          // Only rebuild if we're on the profile tab
          setState(() {});
        }
      }
    });
  }

  // Titles for each screen
  final List<String> _titles = [
    'Home',
    'Projects',
    'Profile',
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Get the current screens with the proper profile page when needed
    final List<Widget> currentScreens = [..._screens];
    if (_selectedIndex == 2) {
      // Only create the profile page when we're on that tab
      final usser = Provider.of<Usser>(context);
      currentScreens[2] = UsserProfile(usser: usser);
    }
    
    return AppScaffold(
      title: _titles[_selectedIndex],
      body: currentScreens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        elevation: 8,
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.folder),
            label: 'Projects',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
