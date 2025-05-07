import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/project_details_view_model.dart';
import '../controllers/project_details_controller.dart';
import '../widgets/sections/progress_section.dart';
import '../widgets/sections/details_section.dart';
import '../widgets/sections/team_members_section.dart';
import '../widgets/sections/meetings_section.dart';
import '../../../features/kanban/screens/kanban_board_screen.dart';
import '../widgets/modals/link_sharing_modal.dart';
import '../widgets/modals/invite_modal.dart';
import '../modals/project_modal_service.dart';
import '../../../features/common/widgets/action_button.dart';
import '../../../features/common/widgets/floating_action_button.dart';
import '../../../features/tasks/modals/task_modal_service.dart';
import '../../../features/common/services/project_service.dart';
import '../../../features/common/services/task_service.dart';
import '../../../features/meetings/modals/meeting_modal_service.dart';
import '../../../features/common/models/task_model.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../../features/common/pdf/index.dart';
import 'package:intl/intl.dart';

class ProjectDetailsScreen extends StatefulWidget {
  final int projectId;
  
  const ProjectDetailsScreen({
    Key? key,
    required this.projectId,
  }) : super(key: key);

  @override
  State<ProjectDetailsScreen> createState() => _ProjectDetailsScreenState();
}

class _ProjectDetailsScreenState extends State<ProjectDetailsScreen> {
  late ProjectDetailsViewModel _viewModel;
  late ProjectDetailsController _controller;
  
  // Progress refresh trigger
  final ValueNotifier<bool> _progressRefreshTrigger = ValueNotifier<bool>(false);
  
  @override
  void initState() {
    super.initState();
    _viewModel = ProjectDetailsViewModel();
    _controller = ProjectDetailsController(_viewModel);
    _loadProjectDetails();
  }
  
  @override
  void dispose() {
    _progressRefreshTrigger.dispose();
    super.dispose();
  }
  
  Future<void> _loadProjectDetails() async {
    await _controller.loadProjectDetails(widget.projectId);
  }
  
  // Generate contribution report
  void _generateContributionReport() async {
    if (_viewModel.hasProject) {
      try {
        // Show loading indicator
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Generating report and exporting PDF...'),
            duration: Duration(seconds: 2),
          ),
        );
        
        final projectId = _viewModel.project!.projectUid;
        
        // Call the backend endpoint
        final response = await http.get(
          Uri.parse('http://localhost:5000/get/contribution/report?project_id=$projectId'),
          headers: {'Content-Type': 'application/json'},
        );
        
        if (response.statusCode == 200) {
          final Map<String, dynamic> data = jsonDecode(response.body);
          
          if (data.containsKey('error')) {
            throw Exception(data['error']);
          }
          
          // Generate and export PDF directly
          try {
            final filePath = await PdfService.generateContributionReportPdf(data);
            
            // Show success message with file path
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('PDF exported to: $filePath'),
                duration: const Duration(seconds: 4),
                action: SnackBarAction(
                  label: 'Dismiss',
                  onPressed: () {
                    ScaffoldMessenger.of(context).hideCurrentSnackBar();
                  },
                ),
              ),
            );
          } catch (e) {
            // Show PDF export error
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Error exporting PDF: $e'),
                backgroundColor: Colors.red,
                duration: const Duration(seconds: 4),
              ),
            );
          }
        } else {
          throw Exception('Failed to generate report: ${response.statusCode}');
        }
      } catch (e) {
        // Show error message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error generating report: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }
  
  void _showAddTaskModal() {
    if (_viewModel.hasProject) {
      TaskModalService.showAddTaskModal(
        context: context,
        projectId: _viewModel.project!.projectUid,
        members: _viewModel.project!.members,
        onTaskCreated: (Task newTask) {
          // Do a full reload to get complete data including member associations
          _loadProjectDetails();
          
          // Show success message
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Task created successfully'),
              duration: Duration(seconds: 2),
            ),
          );
        },
      );
    }
  }
  
  void _showEditProjectModal() {
    if (_viewModel.hasProject) {
      ProjectModalService.showEditProjectModal(
        context: context,
        project: _viewModel.project!,
        onProjectUpdated: () {
          // Refresh project details to reflect changes
          _loadProjectDetails();
        },
      );
    }
  }
  
  void _showDeleteProjectConfirmation() async {
    if (_viewModel.hasProject) {
      final shouldDelete = await ProjectModalService.showDeleteProjectConfirmation(
        context: context,
        projectName: _viewModel.projectName,
      );
      
      if (shouldDelete && mounted) {
        try {
          final success = await ProjectService.deleteProject(_viewModel.project!.projectUid);
          
          if (success && mounted) {
            // Navigate back to projects list
            Navigator.of(context).pop();
            
            // Show success message
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Project deleted successfully'),
                duration: Duration(seconds: 2),
              ),
            );
          } else if (mounted) {
            // Show error message
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Failed to delete project'),
                backgroundColor: Colors.red,
                duration: Duration(seconds: 2),
              ),
            );
          }
        } catch (e) {
          if (mounted) {
            // Show error message
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Error: ${e.toString()}'),
                backgroundColor: Colors.red,
                duration: const Duration(seconds: 3),
              ),
            );
          }
        }
      }
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _viewModel,
      child: Consumer<ProjectDetailsViewModel>(
        builder: (context, viewModel, _) {
          return Scaffold(
            backgroundColor: const Color(0xFF1A1D21),
            appBar: AppBar(
              title: Text(
                viewModel.isLoading ? 'Project Details' : viewModel.projectName,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              backgroundColor: const Color(0xFF1A1D21),
              elevation: 0,
              iconTheme: const IconThemeData(color: Colors.white),
              // Removed edit and delete icons from app bar
            ),
            body: viewModel.isLoading
                ? const Center(child: CircularProgressIndicator())
                : viewModel.hasError
                    ? _buildErrorState(viewModel.errorMessage!)
                    : _buildProjectDetails(),
            // Add floating action button for adding tasks
            floatingActionButton: viewModel.isLoading || viewModel.hasError
                ? null
                : StyledFloatingActionButton(
                    label: 'Add Task',
                    icon: Icons.add_task,
                    onPressed: _showAddTaskModal,
                    backgroundColor: Colors.blue,
                  ),
          );
        },
      ),
    );
  }
  
  Widget _buildErrorState(String errorMessage) {
    return Center(
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
            errorMessage,
            style: const TextStyle(color: Colors.red),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ActionButton(
            label: 'Retry',
            icon: Icons.refresh,
            onPressed: _loadProjectDetails,
          ),
        ],
      ),
    );
  }
  
  Widget _buildProjectDetails() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Action buttons row at the top
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              ActionButton(
                label: 'Edit Project',
                icon: Icons.edit,
                onPressed: _showEditProjectModal,
                backgroundColor: Colors.green,
                scale: 0.9,
              ),
              const SizedBox(width: 12), // Add space between buttons
              ActionButton(
                label: 'Delete Project',
                icon: Icons.delete,
                onPressed: _showDeleteProjectConfirmation,
                backgroundColor: Colors.red,
                scale: 0.9,
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          // Top row with 4 sections
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Progress section
              Expanded(
                child: ProgressSection(
                  viewModel: _viewModel,
                  onGenerateReport: _generateContributionReport,
                  refreshTrigger: _progressRefreshTrigger,
                ),
              ),
              const SizedBox(width: 12),
              
              // Project Details section
              Expanded(
                child: DetailsSection(
                  viewModel: _viewModel,
                  onLinkPress: (title, link) {
                    LinkSharingModal.show(
                      context: context,
                      title: title,
                      link: link,
                      linkType: title.contains('Google') ? 'Google Drive' : 'Discord',
                    );
                  },
                ),
              ),
              const SizedBox(width: 12),
              
              // Team Members section
              Expanded(
                child: TeamMembersSection(
                  viewModel: _viewModel,
                  onInvite: () {
                    if (_viewModel.hasProject) {
                      InviteModal.show(
                        context: context,
                        projectName: _viewModel.projectName,
                        joinCode: _viewModel.joinCode ?? 'No join code available',
                      );
                    }
                  },
                ),
              ),
              const SizedBox(width: 12),
              
              // Meetings section
              Expanded(
                child: MeetingsSection(
                  project: _viewModel.project,
                  onSchedule: () {
                    if (_viewModel.hasProject) {
                      // Show loading indicator
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Loading meetings...'),
                          duration: Duration(milliseconds: 500),
                        ),
                      );
                      
                      // Use the MeetingModalService to show the meeting modal
                      MeetingModalService.showMeetingModal(
                        context: context,
                        project: _viewModel.project!,
                        onMeetingCreated: () {
                          // Explicitly refresh meetings after creating a meeting
                          print('Meeting created callback triggered - refreshing project details');
                          _loadProjectDetails();
                          
                          // After a short delay, refresh again to ensure data is updated
                          Future.delayed(const Duration(milliseconds: 1000), () {
                            _loadProjectDetails();
                          });
                          
                          // Show success message
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Meeting created successfully'),
                              duration: Duration(seconds: 2),
                            ),
                          );
                        },
                      );
                    }
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Tasks Section - Kanban Board
          Card(
            margin: const EdgeInsets.symmetric(vertical: 8.0),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      const Text(
                        'Project Tasks',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 500, // Fixed height for the Kanban board
                    child: _viewModel.hasProject
                      ? KanbanBoardScreen(
                          projectId: _viewModel.project!.projectUid,
                          showActionIcons: true, // Show edit/delete icons on project screen
                          // Pass the most recently added task to the Kanban board
                          // This will trigger the didUpdateWidget method in KanbanBoardScreen
                          // to add the new task to the board without requiring a full reload
                          newTask: _viewModel.projectTasks.isNotEmpty ? _viewModel.projectTasks.last : null,
                          onTaskTap: (task) {
                            // Handle task tap - show a notification for now
                            // In the future, you could create a proper task detail view
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('${task.taskName} - ${task.status.toUpperCase()}'),
                                duration: const Duration(seconds: 2),
                              ),
                            );
                          },
                          onEdit: (task) {
                            // Open the edit task modal
                            TaskModalService.showEditTaskModal(
                              context: context,
                              taskId: task.taskId,
                              projectId: _viewModel.project!.projectUid,
                              members: _viewModel.project!.members,
                              onTaskUpdated: () {
                                // Reload data from server since editing could change many fields
                                _loadProjectDetails();
                                
                                // Show success message
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Task updated successfully'),
                                    duration: Duration(seconds: 2),
                                  ),
                                );
                              },
                            );
                          },
                          onStatusChanged: (task, newStatus) async {
                            // Update the task status in the database
                            await TaskService.updateTaskStatus(task.taskId, newStatus);
                            
                            // Toggle the progress trigger to force ONLY the progress section to update
                            _progressRefreshTrigger.value = !_progressRefreshTrigger.value;
                          },
                          onDelete: (task) async {
                            // Show delete confirmation dialog
                            final shouldDelete = await TaskModalService.showDeleteTaskConfirmation(
                              context: context,
                              taskName: task.taskName,
                            );
                            
                            if (shouldDelete && mounted) {
                              try {
                                // Delete the task
                                final success = await TaskService.deleteTask(task.taskId);
                                
                                if (success && mounted) {
                                // Do a full reload to get updated data after deletion
                                _loadProjectDetails();
                                
                                // Show success message
                                ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                content: Text('Task deleted successfully'),
                                duration: Duration(seconds: 2),
                                ),
                                );
                                } else if (mounted) {
                                  // Show error message
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Failed to delete task'),
                                      backgroundColor: Colors.red,
                                      duration: Duration(seconds: 2),
                                    ),
                                  );
                                }
                              } catch (e) {
                                if (mounted) {
                                  // Show error message
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('Error: ${e.toString()}'),
                                      backgroundColor: Colors.red,
                                      duration: const Duration(seconds: 3),
                                    ),
                                  );
                                }
                              }
                            }
                          },
                        )
                      : const Center(child: Text('No project loaded')),
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