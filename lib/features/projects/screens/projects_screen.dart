import 'package:flutter/material.dart';
import '../widgets/project_card.dart';
import 'project_detail_screen.dart';
import '../modals/add_project_modal.dart';
import '../modals/join_project_modal.dart';
import '../../../usser/usserObject.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ProjectsScreen extends StatefulWidget {
  const ProjectsScreen({Key? key}) : super(key: key);

  @override
  State<ProjectsScreen> createState() => _ProjectsScreenState();
}

class _ProjectsScreenState extends State<ProjectsScreen> {
  List<Map<String, dynamic>> projects = [];
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    loadUserProjects();
  }

  Future<void> loadUserProjects() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final usser = context.read<Usser>();
      
      if (usser.usserID.isEmpty) {
        // If user ID is empty, try to fetch it
        await usser.getID();
      }

      final response = await http.get(
        Uri.parse('http://127.0.0.1:5000/get/user/projects?user_id=${usser.usserID}'),
      );

      if (response.statusCode == 200) {
        final List<dynamic> projectData = json.decode(response.body);
        
        setState(() {
          projects = projectData.map((project) {
            return {
              'id': int.parse(project['id'].toString()),
              'name': project['name'] ?? 'Unnamed Project',
              'deadline': DateTime.parse(project['deadline']),
              'members': int.parse(project['members'].toString() ?? '0'),
              'completedTasks': int.parse(project['completed_tasks'].toString() ?? '0'),
              'totalTasks': int.parse(project['total_tasks'].toString() ?? '0'),
              'color': _getColorFromName(project['name'] ?? ''),
              'description': project['description'] ?? 'No description',
              'uuid': project['uuid'],
              'notification_preference': project['notification_preference'],
              'google_drive_link': project['google_drive_link'],
              'discord_link': project['discord_link'],
              'join_code': project['join_code'],
            };
          }).toList();
          isLoading = false;
        });
      } else {
        throw Exception('Failed to load projects');
      }
    } catch (e) {
      setState(() {
        errorMessage = e.toString();
        isLoading = false;
      });
    }
  }

  // Helper method to get color based on project name (fallback for now)
  Color _getColorFromName(String name) {
    // This is a simple hash-based color assignment
    // In a real app, you'd store the color in the database
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

  Future<void> _refreshProjects() async {
    await loadUserProjects();
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: _refreshProjects,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'My Projects',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Row(
                  children: [
                    ElevatedButton.icon(
                      onPressed: () async {
                        // Show the join project modal
                        final projectId = await showModalBottomSheet<int?>(
                          context: context,
                          isScrollControlled: true,
                          shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                          ),
                          builder: (ctx) => const JoinProjectModal(),
                        );
                        
                        // If joined successfully, navigate to that project's details
                        if (projectId != null) {
                          // First refresh the projects list
                          await loadUserProjects();
                          
                          // Find the joined project
                          final joinedProject = projects.firstWhere(
                            (p) => p['id'] == projectId,
                            orElse: () => {},
                          );
                          
                          if (joinedProject.isNotEmpty) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ProjectDetailScreen(
                                  projectName: joinedProject['name'] as String,
                                  deadline: joinedProject['deadline'] as DateTime,
                                  members: joinedProject['members'] as int,
                                  completedTasks: joinedProject['completedTasks'] as int,
                                  totalTasks: joinedProject['totalTasks'] as int,
                                  color: joinedProject['color'] as Color,
                                  description: joinedProject['description'] as String,
                                  joinCode: joinedProject['join_code'] as String,
                                  projectId: joinedProject['id'].toString(),
                                ),
                              ),
                            );
                          }
                        }
                      },
                      icon: const Icon(Icons.login, size: 18),
                      label: const Text('Join Project'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1E88E5),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton.icon(
                      onPressed: () async {
                        // Show the add project modal
                        final result = await showModalBottomSheet<bool>(
                          context: context,
                          isScrollControlled: true,
                          shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                          ),
                          builder: (ctx) => const AddProjectModal(),
                        );
                        
                        // Refresh the projects list if a new project was created
                        if (result == true) {
                          loadUserProjects();
                        }
                      },
                      icon: const Icon(Icons.add, size: 18),
                      label: const Text('New Project'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1E88E5),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : errorMessage != null
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Error: $errorMessage',
                                style: const TextStyle(color: Colors.red),
                              ),
                              const SizedBox(height: 16),
                              ElevatedButton(
                                onPressed: loadUserProjects,
                                child: const Text('Retry'),
                              ),
                            ],
                          ),
                        )
                      : projects.isEmpty
                          ? const Center(
                              child: Text('No projects yet. Create your first project!'),
                            )
                          : ListView.builder(
                              itemCount: projects.length,
                              itemBuilder: (context, index) {
                                final project = projects[index];
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 16.0),
                                  child: ProjectCard(
                                    name: project['name'] as String,
                                    deadline: project['deadline'] as DateTime,
                                    members: project['members'] as int,
                                    completedTasks: project['completedTasks'] as int,
                                    totalTasks: project['totalTasks'] as int,
                                    color: project['color'] as Color,
                                    description: project['description'] as String,
                                    onTap: () {
                                      // Navigate to project details
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => ProjectDetailScreen(
                                            projectName: project['name'] as String,
                                            deadline: project['deadline'] as DateTime,
                                            members: project['members'] as int,
                                            completedTasks: project['completedTasks'] as int,
                                            totalTasks: project['totalTasks'] as int,
                                            color: project['color'] as Color,
                                            description: project['description'] as String,
                                            joinCode: project['join_code'] as String,
                                            projectId: project['id'].toString(),
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                );
                              },
                            ),
            ),
          ],
        ),
      ),
    );
  }
}
