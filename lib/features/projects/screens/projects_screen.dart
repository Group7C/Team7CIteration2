import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../common/widgets/section_card.dart';
import '../../common/widgets/item_card.dart';
import '../../common/widgets/item_list.dart';
import '../../common/widgets/action_button.dart';
import '../../common/models/project_model.dart';
import '../../common/services/project_service.dart';
import '../../common/services/project_navigation_service.dart';
import '../modals/project_modal_service.dart';
import '../../../usser/usserObject.dart';

class ProjectsScreen extends StatefulWidget {
  const ProjectsScreen({Key? key}) : super(key: key);

  @override
  State<ProjectsScreen> createState() => _ProjectsScreenState();
}

class _ProjectsScreenState extends State<ProjectsScreen> {
  List<Project> userProjects = [];
  bool isLoading = true;
  String? errorMessage;
  
  @override
  void initState() {
    super.initState();
    _loadUserProjects();
  }
  
  Future<void> _loadUserProjects() async {
    try {
      setState(() {
        isLoading = true;
        errorMessage = null;
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
        isLoading = false;
      });
    } catch (e) {
      print('Error loading projects: $e');
      setState(() {
        errorMessage = 'Failed to load projects: $e';
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1D21),
      body: RefreshIndicator(
        onRefresh: _loadUserProjects,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Project count and create project button
              Row(
                children: [
                  Text(
                    '${userProjects.length} Projects',
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 16,
                    ),
                  ),
                  const Spacer(),
                  // Replace icon button with ActionButton
                  ActionButton(
                    label: 'Create Project',
                    icon: Icons.add,
                    onPressed: () {
                      // Show create project modal
                      ProjectsModalService.showCreateProjectModal(
                        context: context,
                        onProjectCreated: () {
                          // Refresh projects list after creation
                          _loadUserProjects();
                        },
                      );
                    },
                    backgroundColor: Colors.blue,
                    scale: 0.9,
                  ),
                ],
              ),
              const SizedBox(height: 16),
              
              // Projects List
              Expanded(
                child: isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : errorMessage != null
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(
                                  Icons.error_outline,
                                  color: Colors.red,
                                  size: 48,
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  errorMessage!,
                                  style: const TextStyle(color: Colors.red),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 24),
                                ElevatedButton(
                                  onPressed: _loadUserProjects,
                                  child: const Text('Retry'),
                                ),
                              ],
                            ),
                          )
                        : userProjects.isEmpty
                            ? _buildEmptyState()
                            : ListView.builder(
                                itemCount: userProjects.length,
                                itemBuilder: (context, index) {
                                  return _buildProjectCard(userProjects[index]);
                                },
                              ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.folder_outlined,
            color: Colors.blue.shade200,
            size: 64,
          ),
          const SizedBox(height: 16),
          const Text(
            'No projects yet',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Create your first project to get started',
            style: TextStyle(color: Colors.white70),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          // Also update the button in the empty state to use ActionButton
          ActionButton(
            label: 'Create Project',
            icon: Icons.add,
            onPressed: () {
              // Show create project modal
              ProjectsModalService.showCreateProjectModal(
                context: context,
                onProjectCreated: () {
                  // Refresh projects list after creation
                  _loadUserProjects();
                },
              );
            },
            backgroundColor: Colors.blue,
            scale: 1.0, // Slightly larger for emphasis in empty state
          ),
        ],
      ),
    );
  }
  
  Widget _buildProjectCard(Project project) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: ItemCard(
        title: project.projName,
        description: 'Deadline: ${_formatDate(project.deadline)}',
        leadingIcon: const Icon(
          Icons.folder_outlined,
          color: Colors.blue,
        ),
        trailingWidget: Row(
          children: [
            const Icon(
              Icons.people,
              size: 16,
              color: Colors.white70,
            ),
            const SizedBox(width: 4),
            Text(
              '${project.members.length}',
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 14,
              ),
            ),
          ],
        ),
        onTap: () {
          // Navigate to project details screen
          ProjectNavigationService.navigateToProjectDetails(
            context,
            project.projectUid,
          );
        },
      ),
    );
  }
  
  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

}
