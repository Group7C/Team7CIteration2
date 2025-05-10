import 'package:flutter/material.dart';
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
  
  String screenTitle = "Team 7C"; // User name 
  
  // Simplified Home Body
  Widget createHomeBody() {
    return const Center(
      child: Text(
        "Home",
        style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
      ),
    );
  }

  // Simplified Projects Body
  Widget createProjectsBody() {
    return const Center(
      child: Text(
        "Projects",
        style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 7, // 7 tabs now
      initialIndex: 0,
      child: Scaffold(       
        appBar: AppBar(
          title: Text(screenTitle),
          actions: [
            IconButton(
              icon: const Icon(Icons.settings),
              onPressed: () {
                // Switch to Settings tab
                DefaultTabController.of(context).animateTo(6);
              },
            ),
          ],
          bottom: TabBar(
            isScrollable: true,
            tabAlignment: TabAlignment.center, 
            tabs: const <Widget>[
              Tab(text: "Home"),
              Tab(text: "Projects"),
              Tab(text: "Add Project"),
              Tab(text: "Edit Project"),
              Tab(text: "Add Task"),
              Tab(text: "Edit Task"),
              Tab(text: "Settings"),
            ],
          ),
        ),
        body: TabBarView(children: <Widget>[
          createHomeBody(),
          createProjectsBody(),
          const AddProjectScreen(),
          const EditProjectScreen(),
          const AddTaskScreen(),
          const EditTaskScreen(),
          const SettingsPage()
        ]),
      ),
    );
  }
}