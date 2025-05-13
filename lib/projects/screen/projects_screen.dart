import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/projects_provider.dart';
import '../../providers/tasks_provider.dart';
import '../project_model.dart';
import '../../Objects/task.dart';
import '../../kanban/kanban.dart';
import '../../shared/components/project/progress.dart';
import '../../shared/components/project/details.dart';
import '../../shared/components/project/members.dart';
import '../../shared/components/project/meetings.dart';
import '../../usser/usserObject.dart';

// main project viewing screen 
// displays selected project details and tasks in kanban format
class ProjectsScreen extends StatefulWidget {
  const ProjectsScreen({Key? key}) : super(key: key);

  @override
  State<ProjectsScreen> createState() => _ProjectsScreenState();
}

class _ProjectsScreenState extends State<ProjectsScreen> {
  int? selectedProjectIndex;
  Project? selectedProject;

  @override
  void initState() {
    super.initState();
    // wait until widget fully built before loading data
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // get user id and fetch their projects
      final userId = context.read<Usser>().usserID;
      if (userId.isNotEmpty) {
        // loads projects then automatically selects first one [default selection]
        context.read<ProjectsProvider>().fetchProjects(userId).then((_) {
          final projects = Provider.of<ProjectsProvider>(context, listen: false).projects;
          if (projects.isNotEmpty) {
            selectedProjectIndex = 0;
            selectedProject = projects[0];
            _loadTasksForProject(selectedProject!);
          }
        });
      }
    });
  }

  // loads tasks for a specific project
  // used when switching between projects or initial load
  void _loadTasksForProject(Project project) async {
    if (project.uuid != null) {
      final taskProvider = Provider.of<TaskProvider>(context, listen: false);
      // refresh tasks from server or cache [ensures latest data]
      await taskProvider.refreshTasksForProjectView(project.uuid);
      
      if (mounted) {
        setState(() {});
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final projects = Provider.of<ProjectsProvider>(context).projects;
    final tasks = Provider.of<TaskProvider>(context).tasks;
    
    // handle empty state - e.g new user with no projects
    if (projects.isEmpty) {
      return const Center(
        child: Text(
          "No projects available",
          style: TextStyle(fontSize: 18),
        ),
      );
    }
    
    // ensure something is selected if we have projects
    if (selectedProjectIndex == null && projects.isNotEmpty) {
      selectedProjectIndex = 0;
      selectedProject = projects[0];
    }
    
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // project dropdown selector at top
          Row(
            children: [
              const Text("Select Project:", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(width: 16),
              Expanded(
                child: DropdownButton<int>(
                  value: selectedProjectIndex,
                  items: List.generate(projects.length, (index) {
                    return DropdownMenuItem(
                      value: index,
                      child: Text(projects[index].projectName),
                    );
                  }),
                  onChanged: (index) {
                    if (index != null) {
                      setState(() {
                        selectedProjectIndex = index;
                        selectedProject = projects[index];
                      });
                      // load tasks for newly selected project
                      _loadTasksForProject(selectedProject!);
                      
                      // refresh project data to get latest meeting info
                      final userId = context.read<Usser>().usserID;
                      if (userId.isNotEmpty) {
                        context.read<ProjectsProvider>().fetchProjects(userId);
                      }
                    }
                  },
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 24),
          
          // main project display area [only shows if a project is selected]
          if (selectedProject != null) 
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // project info components row [progress, details, members, meetings]
                    LayoutBuilder(
                      builder: (context, constraints) {
                        return Row(
                          children: [
                            // shows completion percentage with visual indicator
                            Expanded(
                              child: ProgressComponent(projectUuid: selectedProject!.uuid),
                            ),
                            const SizedBox(width: 16),
                            // shows name, deadline, notification settings
                            Expanded(
                              child: ProjectDetailsComponent(project: selectedProject),
                            ),
                            const SizedBox(width: 16),
                            // shows all project members and their roles
                            Expanded(
                              child: MembersComponent(project: selectedProject),
                            ),
                            const SizedBox(width: 16),
                            // shows upcoming and past meetings
                            Expanded(
                              child: MeetingsComponent(project: selectedProject),
                            ),
                          ],
                        );
                      },
                    ),
                    
                    const SizedBox(height: 32),
                    
                    // tasks kanban board section [drag and drop task management]
                    Center(
                      child: Column(
                        children: [
                          Text(
                            'Project Tasks', 
                            style: TextStyle(
                              fontSize: 24, 
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ),
                          const SizedBox(height: 24),
                          // empty state for when project has no tasks
                          if (tasks.where((task) => task.parentProject == selectedProject!.uuid).isEmpty)
                            const Text(
                              "No tasks for this project yet", 
                              style: TextStyle(fontSize: 14, fontStyle: FontStyle.italic),
                            )
                          // kanban board filtering to only show tasks for this project
                          else
                            SizedBox(
                              height: 500, // extra height for better kanban experience
                              child: KanbanBoard(projectUuid: selectedProject!.uuid),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}