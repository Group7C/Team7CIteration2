import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../common/widgets/section_card.dart';
import '../../common/widgets/item_card.dart';
import '../../common/widgets/item_list.dart';
import '../../common/widgets/horizontal_item_list.dart';
import '../../common/models/project_model.dart';
import '../../common/models/deadline_model.dart';
import '../../common/models/group_model.dart';
import '../../common/services/project_service.dart';
import '../../common/services/project_navigation_service.dart';
import '../../common/models/task_model.dart';
import '../../common/services/task_service.dart';
import '../widgets/group_card.dart';
import '../../../usser/usserObject.dart';
import '../../kanban/screens/kanban_board_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Project> userProjects = [];
  List<Deadline> userDeadlines = [];
  List<Task> userGroupTasks = [];
  bool isLoadingProjects = true;
  bool isLoadingDeadlines = true;
  bool isLoadingGroupTasks = true;
  String? projectsErrorMessage;
  String? deadlinesErrorMessage;
  String? groupTasksErrorMessage;
  
  // Helper function to count the number of members assigned to a task
  int countTaskMembers(Task task) {
    // If assignedMembers is available, use its length
    if (task.assignedMembers.isNotEmpty) {
      return task.assignedMembers.length;
    }
    
    // If we have a members string, count the entries separated by commas
    if (task.members != null && task.members!.isNotEmpty) {
      return task.members!.split(',').length;
    }
    
    // Default to 0 if no member information is found
    return 0;
  }
  
  // Debug version of countTaskMembers that prints details
  int debugCountTaskMembers(Task task) {
    print('Debug task ${task.taskId}: ${task.taskName}');
    print('  - assignedMembers: ${task.assignedMembers.length} members');
    for (var member in task.assignedMembers) {
      print('    - memberId: ${member.membersId}, userId: ${member.userId}, username: ${member.username}');
    }
    print('  - members string: "${task.members}"');
    
    // Get the count
    int count = 0;
    if (task.assignedMembers.isNotEmpty) {
      count = task.assignedMembers.length;
    } else if (task.members != null && task.members!.isNotEmpty) {
      count = task.members!.split(',').length;
    }
    print('  - Total count: $count');
    return count;
  }
  
  @override
  void initState() {
    super.initState();
    _loadUserProjects();
    _loadUserDeadlines();
    _loadUserGroupTasks();
  }
  
  Future<void> _loadUserProjects() async {
    try {
      setState(() {
        isLoadingProjects = true;
        projectsErrorMessage = null;
      });
      
      // Get the current user from Provider
      final Usser currentUser = Provider.of<Usser>(context, listen: false);
      
      // Make sure we have the latest user ID
      await currentUser.getID();
      
      if (currentUser.usserID.isEmpty) {
        throw Exception('User ID not available. Please log in again.');
      }
      
      print('Fetching projects for user ID: ${currentUser.usserID}');
      final projects = await ProjectService.getUserProjects(int.parse(currentUser.usserID));
      print('Received ${projects.length} projects');
      
      setState(() {
        userProjects = projects;
        isLoadingProjects = false;
      });
    } catch (e) {
      print('Error loading projects: $e');
      setState(() {
        projectsErrorMessage = 'Failed to load projects: $e';
        isLoadingProjects = false;
      });
    }
  }
  
  Future<void> _loadUserDeadlines() async {
    try {
      setState(() {
        isLoadingDeadlines = true;
        deadlinesErrorMessage = null;
      });
      
      // Get the current user from Provider
      final Usser currentUser = Provider.of<Usser>(context, listen: false);
      
      // Make sure we have the latest user ID
      await currentUser.getID();
      
      if (currentUser.usserID.isEmpty) {
        throw Exception('User ID not available. Please log in again.');
      }
      
      print('Fetching deadlines for user ID: ${currentUser.usserID}');
      final deadlines = await ProjectService.getUserDeadlines(int.parse(currentUser.usserID));
      print('Received ${deadlines.length} deadlines');
      
      setState(() {
        userDeadlines = deadlines;
        isLoadingDeadlines = false;
      });
    } catch (e) {
      print('Error loading deadlines: $e');
      setState(() {
        deadlinesErrorMessage = 'Failed to load deadlines: $e';
        isLoadingDeadlines = false;
      });
    }
  }
  
  Future<void> _loadUserGroupTasks() async {
    try {
      setState(() {
        isLoadingGroupTasks = true;
        groupTasksErrorMessage = null;
      });
      
      // Get the current user from Provider
      final Usser currentUser = Provider.of<Usser>(context, listen: false);
      
      // Make sure we have the latest user ID
      await currentUser.getID();
      
      if (currentUser.usserID.isEmpty) {
        throw Exception('User ID not available. Please log in again.');
      }
      
      print('Fetching group tasks for user ID: ${currentUser.usserID}');
      final tasks = await TaskService.getGroupTasksByUser(int.parse(currentUser.usserID));
      print('Received ${tasks.length} group tasks');
      
      setState(() {
        userGroupTasks = tasks;
        isLoadingGroupTasks = false;
      });
    } catch (e) {
      print('Error loading group tasks: $e');
      setState(() {
        groupTasksErrorMessage = 'Failed to load group tasks: $e';
        isLoadingGroupTasks = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1D21),
      body: RefreshIndicator(
        onRefresh: () async {
          await Future.wait([
            _loadUserProjects(),
            _loadUserDeadlines(),
            _loadUserGroupTasks(),
          ]);
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top row with 3 sections - with increased height
              SizedBox(
                height: 220, // Trying to force height
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Projects Section
                    Expanded(
                      child: SectionCard(
                        title: 'Projects',
                        content: isLoadingProjects
                            ? const Center(child: CircularProgressIndicator())
                            : projectsErrorMessage != null
                                ? Center(
                                    child: Text(
                                      projectsErrorMessage!,
                                      style: const TextStyle(color: Colors.red),
                                    ),
                                  )
                                : ItemList(
                                    items: userProjects,
                                    itemBuilder: (context, project) {
                                      return ItemCard(
                                        title: project.projName,
                                        date: project.deadline,
                                        leadingIcon: const Icon(
                                          Icons.folder_outlined,
                                          color: Colors.blue,
                                        ),
                                        onTap: () {
                                          // Navigate to project details
                                          ProjectNavigationService.navigateToProjectDetails(
                                            context,
                                            project.projectUid,
                                          );
                                        },
                                      );
                                    },
                                    emptyMessage: 'No projects',
                                    emptyIcon: Icons.folder_outlined,
                                  ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    
                    // Groups Section - shows tasks with multiple members
                    Expanded(
                      child: SectionCard(
                        title: 'Groups',
                        content: isLoadingGroupTasks
                            ? const Center(child: CircularProgressIndicator())
                            : groupTasksErrorMessage != null
                                ? Center(
                                    child: Text(
                                      groupTasksErrorMessage!,
                                      style: const TextStyle(color: Colors.red),
                                    ),
                                  )
                                : ItemList(
                                    // Display all group tasks from the dedicated endpoint
                                    items: userGroupTasks,
                                    itemBuilder: (context, task) {
                                      final taskItem = task as Task;
                                      // Get member count
                                      final int memberCount = taskItem.assignedMembers.length;
                                      return ItemCard(
                                        title: taskItem.taskName,
                                        subtitle: '$memberCount members - Priority: ${taskItem.priority}',
                                        leadingIcon: Icon(
                                          Icons.group,
                                          color: taskItem.status == 'complete' 
                                            ? Colors.green 
                                            : taskItem.status == 'in_progress' 
                                                ? Colors.orange 
                                                : Colors.blue,
                                        ),
                                        onTap: () {
                                          // Navigate to project details
                                          ProjectNavigationService.navigateToProjectDetails(
                                            context,
                                            taskItem.projectUid,
                                          );
                                          
                                          // Show task details in snackbar
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            SnackBar(
                                              content: Text('Group Task: ${taskItem.taskName} - $memberCount members'),
                                              duration: const Duration(seconds: 2),
                                            ),
                                          );
                                        },
                                      );
                                    },
                                    emptyMessage: 'No group tasks found',
                                    emptyIcon: Icons.group_outlined,
                                  ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    
                    // Recent Activity Section
                    Expanded(
                      child: SectionCard(
                        title: 'Recent Activity',
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Task Board Section - Kanban Board
              SectionCard(
                title: 'Task Board',
                height: 400, // Increased height for better visualization
                content: Consumer<Usser>(  // Use Consumer to get current user
                  builder: (context, currentUser, child) {
                    final userId = currentUser.usserID.isNotEmpty 
                      ? int.tryParse(currentUser.usserID) 
                      : null;
                      
                    if (userId == null) {
                      return const Center(
                        child: Text('Please log in to view your tasks'),
                      );
                    }
                    
                    return KanbanBoardScreen(
                      userId: userId,
                      onTaskTap: (task) {
                        // Navigate to the project details
                        ProjectNavigationService.navigateToProjectDetails(
                          context,
                          task.projectUid,
                        );
                      },
                    );
                  },
                ),
                actionButton: OutlinedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.add_task, size: 16),
                  label: const Text('Add Task'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white70,
                    side: const BorderSide(color: Colors.white24),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Upcoming Deadlines Section
              SectionCard(
                title: 'Upcoming Deadlines',
                height: 200,
                content: isLoadingDeadlines
                    ? const Center(child: CircularProgressIndicator())
                    : deadlinesErrorMessage != null
                        ? Center(
                            child: Text(
                              deadlinesErrorMessage!,
                              style: const TextStyle(color: Colors.red),
                            ),
                          )
                        : HorizontalItemList(
                            items: userDeadlines,
                            itemBuilder: HorizontalItemBuilders.deadlineBuilder(),
                            emptyMessage: 'No upcoming deadlines',
                            emptyIcon: Icons.event_busy,
                            itemWidth: 280,
                            itemHeight: 120,
                          ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
