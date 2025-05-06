import '../../projects/screens/project_detail_screen.dart';
import 'package:flutter/material.dart';
import '../containers/home_card_container.dart';
import '../managers/home_content_manager.dart';
import '../contents/groups_list_content.dart'; // Added import for GroupItem
import 'package:http/http.dart' as http;
import 'dart:convert';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Future<Widget> _projectsContent;
  late Future<Widget> _groupsContent;
  late Future<Widget> _activityContent;
  late Future<Widget> _kanbanContent;
  late Future<Widget> _deadlinesContent;
  
  @override
  void initState() {
    super.initState();
    _loadData();
  }
  
  void _loadData() {
    setState(() {
      _projectsContent = HomeContentManager.buildProjectsListContent(
        context,
        onProjectTap: (project) {
          // Navigate to project details
          if (project.id != null) {
            _navigateToProjectDetails(context, project.id!);
          }
        },
      );
      
      _groupsContent = HomeContentManager.buildGroupsListContent(
        context,
        onGroupTap: (group) {
          // Show task collaborator details
          _showCollaboratorDetails(context, group);
        },
      );
      
      _activityContent = HomeContentManager.buildActivityTrackerContent(context);
      _kanbanContent = HomeContentManager.buildKanbanBoardContent(context);
      _deadlinesContent = HomeContentManager.buildDeadlineManagerContent(
        context,
        onDeadlineTap: (deadline) {
          // Navigate to the project associated with this deadline
          if (deadline.id != null && deadline.id!.isNotEmpty) {
            final projectId = deadline.id!.startsWith('project_') 
                ? deadline.id!.substring(8) 
                : deadline.projectId;
                
            if (projectId != null && projectId.isNotEmpty) {
              _navigateToProjectDetails(context, projectId);
            }
          }
        },
      );
    });
  }

  // Helper method to navigate to project details screen
  Future<void> _navigateToProjectDetails(BuildContext context, String projectId) async {
    try {
      // Fetch project details
      final response = await http.get(
        Uri.parse('http://127.0.0.1:5000/project/$projectId'),
      );

      if (response.statusCode == 200) {
        final projectData = json.decode(response.body);
        
        // Navigate to project details screen
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ProjectDetailScreen(
              projectName: projectData['name'] ?? 'Unnamed Project',
              deadline: DateTime.parse(projectData['deadline']),
              members: projectData['members'] ?? 0,
              completedTasks: projectData['completed_tasks'] ?? 0,
              totalTasks: projectData['total_tasks'] ?? 0,
              color: _getColorFromName(projectData['name'] ?? ''),
              description: projectData['description'] ?? 'No description',
              joinCode: projectData['join_code'] ?? '',
              projectId: projectId,
            ),
          ),
        ).then((_) {
          // Refresh data when returning from project details
          _loadData();
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load project details'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // Show task collaboration details
  void _showCollaboratorDetails(BuildContext context, GroupItem group) {
    // Extract project and task info
    final taskTitle = group.taskTitle ?? 'Task';
    final projectName = group.projectName ?? 'Unknown Project';
    
    // Format members list
    final List<Widget> memberWidgets = [];
    if (group.members != null && group.members!.isNotEmpty) {
      group.members!.forEach((name, role) {
        memberWidgets.add(
          ListTile(
            leading: CircleAvatar(
              backgroundColor: _getColorFromName(name),
              child: Text(
                name.isNotEmpty ? name[0].toUpperCase() : '?',
                style: const TextStyle(color: Colors.white),
              ),
            ),
            title: Text(name),
            subtitle: Text('Role: $role'),
          ),
        );
      });
    }

    // Show bottom sheet with group details
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(20),
        ),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(20),
          // Use a higher value for more content (up to 0.9)
          height: MediaQuery.of(context).size.height * 0.6,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      group.name,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const Divider(),
              if (projectName.isNotEmpty)
                ListTile(
                  leading: const Icon(Icons.folder_outlined),
                  title: const Text('Project'),
                  subtitle: Text(projectName),
                  onTap: group.projectId != null && group.projectId!.isNotEmpty 
                      ? () {
                          Navigator.pop(context);
                          _navigateToProjectDetails(context, group.projectId!);
                        }
                      : null,
                ),
              if (taskTitle.isNotEmpty)
                ListTile(
                  leading: const Icon(Icons.task_outlined),
                  title: const Text('Task'),
                  subtitle: Text(taskTitle),
                ),
              const SizedBox(height: 8),
              const Text(
                'Collaborators',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: memberWidgets.isEmpty
                    ? const Center(child: Text('No collaborators found'))
                    : ListView(
                        children: memberWidgets,
                      ),
              ),
            ],
          ),
        );
      },
    );
  }

  // Helper method to get color based on project name
  Color _getColorFromName(String name) {
    // This is a simple hash-based color assignment
    final colors = [
      Colors.blue,
      Colors.purple,
      Colors.green,
      Colors.orange,
      Colors.red,
      Colors.teal,
      Colors.indigo,
      Colors.brown,
    ];
    
    int hash = 0;
    for (int i = 0; i < name.length; i++) {
      hash = ((hash << 5) - hash) + name.codeUnitAt(i);
      hash = hash & hash;
    }
    
    return colors[hash.abs() % colors.length];
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async {
        _loadData();
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              // Top row - three equal cards for main navigation [projects/groups/activity]
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.22,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Projects card [shows active projects with progress]
                    Expanded(
                      child: HomeCardContainer(
                        title: "Projects",
                        actionButton: null, // Removed add button
                        content: FutureBuilder<Widget>(
                          future: _projectsContent,
                          builder: (context, snapshot) {
                            if (snapshot.connectionState == ConnectionState.waiting) {
                              return const Center(child: CircularProgressIndicator());
                            } else if (snapshot.hasError) {
                              return Center(child: Text('Error loading projects'));
                            } else {
                              return snapshot.data ?? const Center(child: Text('No projects'));
                            }
                          },
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    
                    // Groups card [shows teams user belongs to]
                    Expanded(
                      child: HomeCardContainer(
                        title: "Task Collaborators",
                        actionButton: null, // No add button for collaboration groups
                        content: FutureBuilder<Widget>(
                          future: _groupsContent,
                          builder: (context, snapshot) {
                            if (snapshot.connectionState == ConnectionState.waiting) {
                              return const Center(child: CircularProgressIndicator());
                            } else if (snapshot.hasError) {
                              return Center(child: Text('Groups not available'));
                            } else {
                              return snapshot.data ?? const Center(child: Text('No collaboration groups'));
                            }
                          },
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    
                    // Activity feed [shows chronological team activity]
                    Expanded(
                      child: HomeCardContainer(
                        title: "Recent Activity",
                        content: FutureBuilder<Widget>(
                          future: _activityContent,
                          builder: (context, snapshot) {
                            if (snapshot.connectionState == ConnectionState.waiting) {
                              return const Center(child: CircularProgressIndicator());
                            } else if (snapshot.hasError) {
                              return Center(child: Text('Activity not available'));
                            } else {
                              return snapshot.data ?? const Center(child: Text('No activity'));
                            }
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              
              // Middle row - personal task kanban [largest section for task management]
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.35,
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "My Tasks",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Expanded(
                          child: FutureBuilder<Widget>(
                            future: _kanbanContent,
                            builder: (context, snapshot) {
                              if (snapshot.connectionState == ConnectionState.waiting) {
                                return const Center(child: CircularProgressIndicator());
                              } else if (snapshot.hasError) {
                                return Center(child: Text('Error loading tasks'));
                              } else {
                                return snapshot.data ?? const Center(child: Text('No tasks'));
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              
              // Bottom row - deadline timeline [shows upcoming due dates]
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.22,
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              "Upcoming Deadlines",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            // View Calendar button removed
                          ],
                        ),
                        const SizedBox(height: 16),
                        Expanded(
                          child: FutureBuilder<Widget>(
                            future: _deadlinesContent,
                            builder: (context, snapshot) {
                              if (snapshot.connectionState == ConnectionState.waiting) {
                                return const Center(child: CircularProgressIndicator());
                              } else if (snapshot.hasError) {
                                return Center(child: Text('Error loading deadlines'));
                              } else {
                                return snapshot.data ?? const Center(child: Text('No deadlines'));
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}