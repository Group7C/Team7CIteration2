import 'package:flutter/material.dart';
import 'kanban.dart';
import '../shared/components/action_button.dart';

// This is just a testing screen I used to separate the development of the kanban from the rest of the app
// this was just for development and we can delete it later before final submit
// If  you want to see it add it to the app bar in home.dart (did same for component development)

class KanbanTestScreen extends StatefulWidget {
  const KanbanTestScreen({super.key});

  @override
  State<KanbanTestScreen> createState() => _KanbanTestScreenState();
}

class _KanbanTestScreenState extends State<KanbanTestScreen> {
  bool showUserTasks = true; 
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // Header section
          Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                const Icon(
                  Icons.view_kanban,
                  size: 48,
                  color: Colors.blue,
                ),
                const SizedBox(height: 8),
                Text(
                  'Kanban Board',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: 16),
                // Button row
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ActionButton(
                      label: 'User Tasks',
                      icon: Icons.person,
                      isPrimary: showUserTasks,
                      onPressed: () {
                        setState(() {
                          showUserTasks = true;
                        });
                      },
                    ),
                    const SizedBox(width: 16),
                    ActionButton(
                      label: 'Project Tasks',
                      icon: Icons.work,
                      isPrimary: !showUserTasks,
                      onPressed: () {
                        setState(() {
                          showUserTasks = false;
                        });
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Kanban board placed here
          const Expanded(
            child: KanbanBoard(),
          ),
        ],
      ),
    );
  }
}
