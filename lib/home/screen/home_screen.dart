import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/projects_provider.dart';
import '../../providers/tasks_provider.dart';
import '../../projects/project_model.dart';
import '../../Objects/task.dart';
import '../../usser/usserObject.dart';
import '../../kanban/kanban.dart';
import '../../shared/components/home/projects.dart';
import '../../shared/components/home/groups.dart';
import '../../shared/components/home/details.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<Usser>(context);
    final projects = Provider.of<ProjectsProvider>(context).projects;
    final tasks = Provider.of<TaskProvider>(context).tasks;
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Home Components Row [ Projects, Groups, Details ]
          LayoutBuilder(
            builder: (context, constraints) {
              return Row(
                children: const [
                  Expanded(
                    child: ProjectsComponent(),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: GroupsComponent(),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: DetailsComponent(),
                  ),
                ],
              );
            },
          ),
          
          const SizedBox(height: 24),
          const Divider(),
          const SizedBox(height: 24),
          
          // Kanban row
          const Center(
            child: Text(
              "My Tasks",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 16),
          if (tasks.isEmpty)
            const Center(
              child: Text("No tasks yet", style: TextStyle(fontSize: 16)),
            )
          else
            const Center(
              // Kanban board
              child: KanbanBoard(),
            ),
        ],
      ),
    );
  }
}
