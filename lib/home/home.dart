import 'package:flutter/material.dart';
import 'screen/home_screen.dart';
import '../projects/screen/projects_screen.dart';
import 'settings_page.dart';
import '../tasks/add_task_screen.dart';
import '../tasks/edit_task_screen.dart';
import '../projects/add_project_screen.dart';
import '../projects/edit_project_screen.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  
  String screenTitle = "Team 7C"; 
  
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 7, 
      initialIndex: 0,
      child: Scaffold(       
        appBar: AppBar(
          title: Text(screenTitle),
          actions: [
            // Probably remove this icon later after introducing Jamie's settings page properly
            IconButton(
              icon: const Icon(Icons.settings),
              onPressed: () {
                DefaultTabController.of(context).animateTo(7);
              },
            ),
          ],
          bottom: TabBar(
            isScrollable: true,
            tabAlignment: TabAlignment.center,
            indicatorSize: TabBarIndicatorSize.label,
            indicator: UnderlineTabIndicator(
              borderSide: BorderSide(width: 3.0, color: Theme.of(context).colorScheme.primary),
              insets: EdgeInsets.symmetric(horizontal: 16.0),
            ),
            labelColor: Theme.of(context).colorScheme.primary,
            unselectedLabelColor: Colors.grey[600],
            labelStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
            unselectedLabelStyle: TextStyle(fontWeight: FontWeight.normal, fontSize: 14),
            tabs: const <Widget>[
              Tab(text: "Home"),
              Tab(text: "Projects"),
              Tab(text: "Add/Join Project"),
              Tab(text: "Edit Project"),
              Tab(text: "Add Task"),
              Tab(text: "Edit Task"),
              Tab(text: "Settings"),
            ],
          ),
        ),
        body: TabBarView(children: <Widget>[
          const HomeScreen(),
          const ProjectsScreen(),
          const AddProjectScreen(),
          const EditProjectScreen(),
          const AddTaskScreen(), 
          const EditTaskScreen(),
          const SettingsPage(),
        ]),
      ),
    );
  }
}
