import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../widgets/containers/project_details_container.dart';
import '../managers/project_details_manager.dart';
import '../../shared/widgets/action_button.dart';
import '../../tasks/index.dart';
import '../models/project.dart';
import '../widgets/meetings/attendance/meeting_attendance_modal.dart';
import '../widgets/reports/contribution/contribution_report_modal.dart';
import 'package:intl/intl.dart';
import '../../kanban/board/containers/project_kanban.dart';
import '../../kanban/board/models/kanban_task.dart';
import '../modals/invite_members_modal.dart';

class ProjectDetailScreen extends StatefulWidget {
  final String projectName;
  final DateTime deadline;
  final int members;
  final int completedTasks;
  final int totalTasks;
  final Color color;
  final String description;
  final String joinCode;
  final String projectId;

  const ProjectDetailScreen({
    Key? key,
    required this.projectName,
    required this.deadline,
    required this.members,
    required this.completedTasks,
    required this.totalTasks,
    required this.color,
    required this.description,
    required this.joinCode,
    required this.projectId,
  }) : super(key: key);

  @override
  State<ProjectDetailScreen> createState() => _ProjectDetailScreenState();
}

class _ProjectDetailScreenState extends State<ProjectDetailScreen> {
  List<Map<String, dynamic>> projectMembers = [];
  bool isLoadingMembers = true;
  List<Map<String, dynamic>> projectTasks = [];
  bool isLoadingTasks = true;

  @override
  void initState() {
    super.initState();
    _loadProjectMembers();
    _loadProjectTasks();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Reload tasks when returning to this screen
    _loadProjectTasks();
  }

  Future<void> _loadProjectMembers() async {
    setState(() {
      isLoadingMembers = true;
    });

    try {
      final response = await http.get(
        Uri.parse('http://127.0.0.1:5000/project/${widget.projectId}/members'),
      );

      if (response.statusCode == 200) {
        final List<dynamic> memberData = json.decode(response.body);
        
        setState(() {
          projectMembers = memberData.map((member) => {
            'id': member['id'],
            'username': member['username'],
            'email': member['email'],
            'profile_picture': member['profile_picture'],
          }).toList();
          isLoadingMembers = false;
        });
      } else {
        throw Exception('Failed to load project members');
      }
    } catch (e) {
      setState(() {
        isLoadingMembers = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error loading project members: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _loadProjectTasks() async {
    setState(() {
      isLoadingTasks = true;
    });

    try {
      final response = await http.get(
        Uri.parse('http://127.0.0.1:5000/project/${widget.projectId}/tasks'),
      );

      if (response.statusCode == 200) {
        final List<dynamic> taskData = json.decode(response.body);
        
        // Debug print to see what we're getting
        print('Loaded tasks: $taskData');
        
        setState(() {
          projectTasks = taskData.map((task) => {
            'id': task['id'].toString(),
            'title': task['title'],
            'description': task['description'],
            'due_date': task['due_date'],
            'status': task['status'],
            'priority': task['priority'],
            'assignee_username': task['assignee_username'],
            'assignee_id': task['assignee_id'],
            'project_name': task['project_name'],
            'project_id': task['project_id'].toString(),
          }).toList();
          isLoadingTasks = false;
        });
      } else {
        setState(() {
          isLoadingTasks = false;
        });
      }
    } catch (e) {
      setState(() {
        isLoadingTasks = false;
      });
      print('Error loading tasks: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final daysRemaining = widget.deadline.difference(DateTime.now()).inDays;
    final isOverdue = daysRemaining < 0;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.projectName),
        backgroundColor: widget.color.withOpacity(0.8),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Project header with progress
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: ProjectDetailsContainer(
                icon: Icons.pie_chart,
                title: 'Progress',
                iconColor: widget.color,
                content: ProjectDetailsManager.buildProgressContent(
                  widget.completedTasks, 
                  widget.totalTasks, 
                  widget.color
                ),
              ),
            ),
            
            // Description and Team Members Row
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Description Section
                  Expanded(
                    flex: 3,
                    child: ProjectDetailsContainer(
                      icon: Icons.description,
                      title: 'Description',
                      iconColor: Colors.purple,
                      content: ProjectDetailsManager.buildDescriptionContent(
                        widget.description
                      ),
                    ),
                  ),
                  
                  const SizedBox(width: 16),
                  
                  // Team Members Section
                  Expanded(
                    flex: 2,
                    child: ProjectDetailsContainer(
                      icon: Icons.people,
                      title: 'Team Members',
                      iconColor: Colors.indigo,
                      actionLabel: 'Invite Members',
                      actionIcon: Icons.person_add,
                      onAction: () {
                        // Show invite members modal
                        showModalBottomSheet(
                          context: context,
                          shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                          ),
                          builder: (ctx) => InviteMembersModal(
                            joinCode: widget.joinCode,
                            projectName: widget.projectName,
                          ),
                        );
                      },
                      content: ProjectDetailsManager.buildTeamMembersContent(
                        widget.members
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            // Info sections: Deadline, Meetings, Analysis
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Deadline Section
                  Expanded(
                    child: ProjectDetailsContainer(
                      icon: Icons.calendar_today,
                      title: 'Deadline',
                      iconColor: isOverdue ? Colors.red : Colors.blue,
                      content: ProjectDetailsManager.buildDeadlineContent(
                        widget.deadline
                      ),
                    ),
                  ),
                  
                  const SizedBox(width: 16),
                  
                  // Meetings Section
                  Expanded(
                    child: ProjectDetailsContainer(
                      icon: Icons.groups,
                      title: 'Meetings',
                      iconColor: Colors.blue,
                      actionLabel: 'Schedule Meeting',
                      actionIcon: Icons.calendar_month,
                      onAction: () {
                        // Create a Project model instance with the current project data
                        final project = Project(
                          id: 1,
                          name: widget.projectName,
                          deadline: widget.deadline,
                          joinCode: 'ABC123',
                          notificationPreference: NotificationFrequency.weekly,
                          members: List.generate(
                            widget.members,
                            (index) => ProjectMember(
                              id: index + 1,
                              username: index == 0 ? 'You' : 'Member ${index + 1}',
                              isOwner: index == 0,
                              role: index == 0 ? 'editor' : 'viewer',
                              joinDate: DateTime.now().subtract(Duration(days: 30 + index * 5)),
                            ),
                          ),
                          completedTasks: widget.completedTasks,
                          totalTasks: widget.totalTasks,
                          description: widget.description,
                          colour: widget.color,
                        );

                        // Show the meeting modal
                        showModalBottomSheet(
                          context: context,
                          isScrollControlled: true,
                          shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                          ),
                          builder: (ctx) => MeetingAttendanceModal(
                            project: project,
                          ),
                        ).then((result) {
                          // If a meeting date was returned (scheduled), update the UI
                          if (result != null && result is String) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Next meeting scheduled for $result'),
                                backgroundColor: Colors.green,
                              ),
                            );
                            
                            // In a real app, you would update your state management system here
                            // For this example, we'll just show a snackbar with the scheduled date
                          }
                        });
                      },
                      content: ProjectDetailsManager.buildMeetingsContent(),
                    ),
                  ),
                  
                  const SizedBox(width: 16),
                  
                  // Analysis Section
                  Expanded(
                    child: ProjectDetailsContainer(
                      icon: Icons.analytics,
                      title: 'Analysis',
                      iconColor: Colors.teal,
                      actionLabel: 'Generate Report',
                      actionIcon: Icons.assessment,
                      onAction: () {
                        // Create a Project model instance with the current project data
                        final project = Project(
                          id: 1,
                          name: widget.projectName,
                          deadline: widget.deadline,
                          joinCode: 'ABC123',
                          notificationPreference: NotificationFrequency.weekly,
                          members: List.generate(
                            widget.members,
                            (index) => ProjectMember(
                              id: index + 1,
                              username: index == 0 ? 'You' : 'Member ${index + 1}',
                              isOwner: index == 0,
                              role: index == 0 ? 'editor' : 'viewer',
                              joinDate: DateTime.now().subtract(Duration(days: 30 + index * 5)),
                            ),
                          ),
                          completedTasks: widget.completedTasks,
                          totalTasks: widget.totalTasks,
                          description: widget.description,
                          colour: widget.color,
                        );

                        // Show the contribution report modal
                        showModalBottomSheet(
                          context: context,
                          isScrollControlled: true,
                          shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                          ),
                          builder: (ctx) => ContributionReportModal(
                            project: project,
                          ),
                        );
                      },
                      content: ProjectDetailsManager.buildAnalysisContent(
                        widget.completedTasks, 
                        widget.totalTasks
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            // Tasks section - Kanban Board Integration
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: ProjectDetailsContainer(
                icon: Icons.task_alt,
                title: 'Tasks',
                iconColor: Colors.green,
                actionLabel: 'Add Task',
                actionIcon: Icons.add_task,
                onAction: () {
                  // Show the add task modal
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                    ),
                    builder: (ctx) {
                      // Get usernames from actual project members
                      final memberNames = projectMembers.map((member) => member['username'] as String).toList();
                      
                      return AddTaskModal(
                        projectName: widget.projectName,
                        projectId: widget.projectId,  // Use actual project ID, not transformed name
                        projectMembers: memberNames.isNotEmpty ? memberNames : ['No members'],
                        onTaskAdded: (task) {
                          // Reload tasks after adding a new one
                          _loadProjectTasks();
                          
                          // Refresh the project details or update the UI as needed
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Task added successfully!'),
                              backgroundColor: Colors.green,
                            ),
                          );
                        },
                      );
                    },
                  );
                },
                content: Container(
                  height: 450, // Set an appropriate height for the Kanban board
                  child: ProjectKanban(
                    projectId: widget.projectId,  // FIXED: Use actual project ID
                    projectColor: widget.color,
                    tasks: projectTasks,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: ActionButton(
        label: 'Add Task',
        icon: Icons.add_task,
        backgroundColor: widget.color,
        scale: 1.0, // Full size for the main action button
        onPressed: () {
          // Show the add task modal
          showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
          ),
          builder: (ctx) {
          // Get usernames from actual project members
          final memberNames = projectMembers.map((member) => member['username'] as String).toList();
          
          return AddTaskModal(
          projectName: widget.projectName,
          projectId: widget.projectId,  // Use actual project ID, not transformed name
          projectMembers: memberNames.isNotEmpty ? memberNames : ['No members'],
          onTaskAdded: (task) {
          // Reload tasks after adding a new one
          _loadProjectTasks();
          
          // Refresh the project details or update the UI as needed
          ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Task added successfully!'),
            backgroundColor: Colors.green,
          ),
          );
          },
          );
          },
          );
        },
      ),
    );
  }
}
