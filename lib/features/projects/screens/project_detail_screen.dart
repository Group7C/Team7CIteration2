import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:math' show pi, cos, sin;
import '../widgets/containers/project_details_container.dart';
import '../managers/project_details_manager.dart';
import '../../shared/widgets/action_button.dart';
import '../../tasks/index.dart';
import '../models/project.dart';
import '../../../common/enums/notification_frequency.dart';
import '../widgets/meetings/attendance/meeting_attendance_modal.dart';
import '../widgets/reports/contribution/contribution_report_modal.dart';
import 'package:intl/intl.dart';
import '../../kanban/board/containers/project_kanban.dart';
import '../../kanban/board/models/kanban_task.dart';
import '../modals/invite_members_modal.dart';
import '../modals/edit_project_modal.dart';
import 'package:confetti/confetti.dart';

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
  
  // Meeting date variables
  String? lastMeetingDate;
  String? nextMeetingDate;
  bool isLoadingMeetings = true;
  
  // Format dates for display
  String? formattedLastMeeting;
  String? formattedNextMeeting;
  Map<String, dynamic>? lastMeeting;
  Map<String, dynamic>? nextMeeting;
  
  // Confetti controller
  late ConfettiController _completedConfettiController;

  @override
  void initState() {
    super.initState();
    _loadProjectMembers();
    _loadProjectTasks();
    _loadMeetingDates();
    
    // Initialize confetti controller
    _completedConfettiController = ConfettiController(duration: const Duration(seconds: 2));
  }
  
  Future<void> _loadMeetingDates() async {
    setState(() {
      isLoadingMeetings = true;
    });

    try {
      final response = await http.get(
        Uri.parse('http://127.0.0.1:5000/project/${widget.projectId}/meetings'),
      );

      print('Meeting API response: ${response.body}');

      if (response.statusCode == 200) {
        try {
          // Try to get the specific format for project meetings endpoint
          // The API might have both formats depending on the endpoint
          final data = json.decode(response.body);
          
          // First try to handle as an array of meetings
          if (data is List) {
            final List<dynamic> meetings = data;
            _processMeetingsArray(meetings);
          } 
          // Then try to handle as an object with last/next meeting fields
          else if (data is Map) {
            // Process as a map with string keys
            final Map<String, dynamic> meetingData = {};
            (data as Map).forEach((key, value) {
              meetingData[key.toString()] = value;
            });
            _processMeetingObject(meetingData);
          }
          // If neither works, try the other endpoint for meetings
          else {
            _tryAlternativeMeetingsEndpoint();
          }
        } catch (e) {
          print('Error parsing meeting data: $e');
          setState(() {
            lastMeetingDate = 'Error loading';
            nextMeetingDate = null;
            isLoadingMeetings = false;
          });
          // Try alternate endpoint if parsing fails
          _tryAlternativeMeetingsEndpoint();
        }
        
      } else {
        setState(() {
          lastMeetingDate = 'Not available';
          nextMeetingDate = null;
          isLoadingMeetings = false;
        });
      }
    } catch (e) {
      print('Error loading meeting dates: $e');
      setState(() {
        lastMeetingDate = 'Error loading';
        nextMeetingDate = null;
        isLoadingMeetings = false;
      });
    }
  }
  
  // Process array of meetings from the API
  void _processMeetingsArray(List<dynamic> meetings) {
    if (meetings.isEmpty) {
      // No meetings found
      setState(() {
        lastMeetingDate = 'Not recorded';
        nextMeetingDate = null; // No upcoming meetings
        isLoadingMeetings = false;
      });
      return;
    }
    
    // Sort meetings by date
    meetings.sort((a, b) => a['date'].compareTo(b['date']));
    
    // Find the latest past meeting
    DateTime now = DateTime.now();
    
    for (var meeting in meetings) {
      DateTime meetingDate = DateTime.parse(meeting['date']);
      if (meetingDate.isBefore(now) || meetingDate.isAtSameMomentAs(now)) {
        lastMeeting = meeting;
      }
    }
    
    // Find the earliest upcoming meeting
    for (var meeting in meetings) {
      DateTime meetingDate = DateTime.parse(meeting['date']);
      if (meetingDate.isAfter(now)) {
        if (nextMeeting == null) {
          nextMeeting = meeting;
        } else {
          DateTime nextMeetingDate = DateTime.parse(nextMeeting!['date']);
          if (meetingDate.isBefore(nextMeetingDate)) {
            nextMeeting = meeting;
          }
        }
      }
    }
    
    _formatAndUpdateMeetings();
  }
  
  // Process object with last_meeting_date and next_meeting_date fields
  void _processMeetingObject(Map<String, dynamic> data) {
    print('Processing meeting object: $data');
    
    if (data.containsKey('last_meeting_date') && data['last_meeting_date'] != null) {
      formattedLastMeeting = _formatDate(data['last_meeting_date'].toString());
    } else {
      formattedLastMeeting = 'Not recorded';
    }
    
    if (data.containsKey('next_meeting_date') && data['next_meeting_date'] != null) {
      formattedNextMeeting = _formatDate(data['next_meeting_date'].toString());
    }
    
    setState(() {
      lastMeetingDate = formattedLastMeeting;
      nextMeetingDate = formattedNextMeeting;
      isLoadingMeetings = false;
    });
  }
  
  // Format a date string
  String _formatDate(String dateStr) {
    try {
      final date = DateTime.parse(dateStr);
      return DateFormat('MMM d, yyyy').format(date);
    } catch (e) {
      print('Error formatting date $dateStr: $e');
      return dateStr; // Return original if parsing fails
    }
  }
  
  // Format and update meeting dates in the UI
  void _formatAndUpdateMeetings() {
    if (lastMeeting != null) {
      formattedLastMeeting = _formatDate(lastMeeting!['date']);
    } else {
      formattedLastMeeting = 'Not recorded';
    }
    
    if (nextMeeting != null) {
      formattedNextMeeting = _formatDate(nextMeeting!['date']);
    }
    
    setState(() {
      lastMeetingDate = formattedLastMeeting;
      nextMeetingDate = formattedNextMeeting;
      isLoadingMeetings = false;
    });
  }
  
  void _tryAlternativeMeetingsEndpoint() {
    http.get(
      Uri.parse('http://127.0.0.1:5000/meetings/${widget.projectId}/dates'),
    ).then((response) {
      print('Alternative endpoint response: ${response.body}');
      
      if (response.statusCode == 200) {
        try {
          final data = json.decode(response.body);
          
          if (data is Map) {
            // Convert to Map<String, dynamic>
            final Map<String, dynamic> meetingData = {};
            data.forEach((key, value) {
              meetingData[key.toString()] = value;
            });
            _processMeetingObject(meetingData);
          }
        } catch (e) {
          print('Error processing alternative endpoint: $e');
          // Keep existing meeting dates if available
        }
      }
    }).catchError((e) {
      print('Error with alternative endpoint: $e');
      // Keep existing meeting dates if available
    });
  }
  
  @override
  void dispose() {
    _completedConfettiController.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Reload data when returning to this screen
    _loadProjectTasks();
    _loadMeetingDates();
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

  // Count completed tasks
  int _getCompletedTasksCount() {
    return projectTasks.where((task) => 
      task['status'] != null && 
      task['status'].toString().toLowerCase() == 'completed'
    ).length;
  }
  
  // Method to handle task status changes and trigger confetti
  void _handleTaskStatusChange(String taskId, String newStatus) {
    // Reload tasks to update progress
    _loadProjectTasks();
    
    // Play confetti effect only for completed tasks
    if (newStatus == 'completed') {
      _completedConfettiController.play();
    }
  }
  
  // Custom star shape for confetti particles
  Path drawStar(Size size) {
    // Method to create a star-shaped confetti
    double degToRad(double deg) => deg * (pi / 180.0);
    
    const numberOfPoints = 5;
    final halfWidth = size.width / 2;
    final externalRadius = halfWidth;
    final internalRadius = halfWidth / 2.5;
    final degreesPerStep = degToRad(360 / numberOfPoints);
    final halfDegreesPerStep = degreesPerStep / 2;
    final path = Path();
    final fullAngle = degToRad(360);
    
    path.moveTo(size.width, halfWidth);
    
    for (double step = 0; step < fullAngle; step += degreesPerStep) {
      path.lineTo(
        halfWidth + externalRadius * cos(step),
        halfWidth + externalRadius * sin(step),
      );
      path.lineTo(
        halfWidth + internalRadius * cos(step + halfDegreesPerStep),
        halfWidth + internalRadius * sin(step + halfDegreesPerStep),
      );
    }
    
    path.close();
    return path;
  }

  @override
  Widget build(BuildContext context) {
    final daysRemaining = widget.deadline.difference(DateTime.now()).inDays;
    final isOverdue = daysRemaining < 0;

    return Stack(
      children: [
        // Main Scaffold with all UI elements
        Scaffold(
          appBar: AppBar(
            title: Text(widget.projectName),
            backgroundColor: widget.color.withOpacity(0.8),
            actions: [
              // Add edit button to the app bar as a styled button instead of an icon
              Padding(
                padding: const EdgeInsets.only(right: 16.0),
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.edit, size: 18),
                  label: const Text('Edit Project'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1E88E5),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onPressed: () {
                    // Get the notification preference from enum string
                    NotificationFrequency notificationPreference = NotificationFrequency.weekly;
                    try {
                      notificationPreference = NotificationFrequency.values.firstWhere(
                        (e) => e.name.toLowerCase() == 'weekly'
                      );
                    } catch (e) {
                      print('Error parsing notification preference: $e');
                    }
                    
                    // Show the edit project modal
                    showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                      ),
                      builder: (ctx) => EditProjectModal(
                        projectId: widget.projectId,
                        projectName: widget.projectName,
                        description: widget.description,
                        deadline: widget.deadline,
                        googleDriveLink: '', // Would come from API
                        discordLink: '', // Would come from API
                        notificationPreference: notificationPreference, 
                        projectColor: widget.color,
                        onProjectUpdated: () {
                          // Refresh project details
                          // In a real app, this would reload the project data
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Project updated successfully! Refresh to see changes.'),
                              backgroundColor: Colors.green,
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
          body: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Top row with Progress and Project Details
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Project header with progress
                      Expanded(
                        flex: 1,
                        child: ProjectDetailsContainer(
                          icon: Icons.pie_chart,
                          title: 'Progress',
                          iconColor: widget.color,
                          content: isLoadingTasks
                            ? const Center(child: CircularProgressIndicator())
                            : ProjectDetailsManager.buildProgressContent(
                              _getCompletedTasksCount(),
                              projectTasks.length,
                              widget.color,
                                tasks: projectTasks,
                              ),
                        ),
                      ),
                      
                      const SizedBox(width: 16),
                      
                      // Enhanced Description Section with Deadline, Links, etc.
                      Expanded(
                        flex: 2,
                        child: ProjectDetailsContainer(
                          icon: Icons.description,
                          title: 'Project Details',
                          iconColor: Colors.purple,
                          content: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Row with Description, Deadline and Shared Resources - Three columns
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Project Description Section (Column 1)
                                  Expanded(
                                    flex: 1,
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        const Text(
                                          'Description',
                                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          widget.description.isEmpty ? 'No description provided.' : widget.description,
                                        ),
                                      ],
                                    ),
                                  ),
                                  
                                  const SizedBox(width: 16),
                                  
                                  // Deadline Information Section (Column 2)
                                  Expanded(
                                    flex: 1,
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Icon(
                                              Icons.calendar_today,
                                              color: isOverdue ? Colors.red : Colors.blue,
                                              size: 18,
                                            ),
                                            const SizedBox(width: 8),
                                            Text(
                                              'Deadline',
                                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          '${DateFormat('d MMMM yyyy').format(widget.deadline)} '
                                          '(${isOverdue ? "Overdue by ${-daysRemaining} days" : "${daysRemaining} days left"})',
                                          style: TextStyle(
                                            color: isOverdue ? Colors.red : null,
                                            fontWeight: isOverdue ? FontWeight.bold : null,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),

                                  const SizedBox(width: 16),
                                  
                                  // Shared Resources Section (Column 3)
                                  Expanded(
                                    flex: 1,
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        const Text(
                                          'Shared Resources',
                                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                        ),
                                        const SizedBox(height: 8),
                                        // Resource Links (buttons with consistent width)
                                        Column(
                                          crossAxisAlignment: CrossAxisAlignment.stretch, // Make children stretch to fill width
                                          children: [
                                            // Google Drive Link - smaller button
                                            InkWell(
                                              onTap: () {
                                                ScaffoldMessenger.of(context).showSnackBar(
                                                  const SnackBar(content: Text('Opening Google Drive link...')),
                                                );
                                              },
                                              child: Card(
                                                elevation: 0,
                                                margin: EdgeInsets.only(bottom: 6.0),
                                                color: const Color(0xFF1E88E5),
                                                child: Padding(
                                                  padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 10.0),
                                                  child: Row(
                                                    mainAxisAlignment: MainAxisAlignment.start,
                                                    children: const [
                                                      Icon(Icons.cloud, color: Colors.white, size: 16),
                                                      SizedBox(width: 8),
                                                      Text('Google Drive', style: TextStyle(fontSize: 13, color: Colors.white)),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ),
                                            
                                            // Discord Link - smaller button
                                            InkWell(
                                              onTap: () {
                                                ScaffoldMessenger.of(context).showSnackBar(
                                                  const SnackBar(content: Text('Opening Discord link...')),
                                                );
                                              },
                                              child: Card(
                                                elevation: 0,
                                                margin: const EdgeInsets.only(bottom: 6.0),
                                                color: const Color(0xFF1E88E5),
                                                child: Padding(
                                                  padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 10.0),
                                                  child: Row(
                                                    mainAxisAlignment: MainAxisAlignment.start,
                                                    children: const [
                                                      Icon(Icons.discord, color: Colors.white, size: 16),
                                                      SizedBox(width: 8),
                                                      Text('Discord', style: TextStyle(fontSize: 13, color: Colors.white)),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Row with Team Members, Meetings, and Analysis
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Team Members Section
                      Expanded(
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
                          content: isLoadingMembers
                            ? const Center(child: CircularProgressIndicator())
                            : Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Display member avatars in a row
                                  Wrap(
                                    spacing: 12, // gap between adjacent members
                                    runSpacing: 10, // gap between lines
                                    children: projectMembers.map((member) => Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        CircleAvatar(
                                          radius: 20,
                                          backgroundColor: Colors.blueGrey,
                                          child: member['profile_picture'] != null
                                            ? Image.network(member['profile_picture'])
                                            : Text(member['username'][0].toUpperCase()),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          member['username'],
                                          style: const TextStyle(fontSize: 12),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ],
                                    )).toList(),
                                  ),
                                ],
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
                              id: int.tryParse(widget.projectId) ?? 1,
                              name: widget.projectName,
                              deadline: widget.deadline,
                              joinCode: widget.joinCode,
                              notificationPreference: NotificationFrequency.weekly,
                              // Use the actual project members if available
                              members: projectMembers.isNotEmpty
                                ? projectMembers.map((m) => ProjectMember(
                                    id: m['id'],
                                    username: m['username'],
                                    isOwner: false, // Can't determine this from the data
                                    role: 'editor', // Default role
                                    joinDate: DateTime.now(), // Don't have this data
                                  )).toList()
                                : List.generate(
                                    2, // Default 2 members if none loaded yet
                                    (index) => ProjectMember(
                                      id: index + 1,
                                      username: index == 0 ? 'User 1' : 'User 2',
                                      isOwner: index == 0,
                                      role: 'editor',
                                      joinDate: DateTime.now(),
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
                                print('Meeting scheduled: $result');
                                
                                // Try to format the date consistently
                                try {
                                  // If the result is already a formatted date, use it directly
                                  setState(() {
                                    nextMeetingDate = result;
                                  });
                                  
                                  // Also call the API to make sure server state is updated
                                  _loadMeetingDates();
                                } catch (e) {
                                  print('Error processing scheduled meeting date: $e');
                                  setState(() {
                                    nextMeetingDate = result; // Use as-is if parsing fails
                                  });
                                }
                                
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Next meeting scheduled for $result'),
                                    backgroundColor: Colors.green,
                                  ),
                                );
                              }
                            });
                          },
                          content: ProjectDetailsManager.buildMeetingsContent(
                            lastMeetingDate: lastMeetingDate,
                            nextMeetingDate: nextMeetingDate,
                          ),
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
                          content: isLoadingTasks
                            ? const Center(child: CircularProgressIndicator())
                            : ProjectDetailsManager.buildAnalysisContent(
                              _getCompletedTasksCount(),
                              projectTasks.length
                            ),
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Tasks section - Kanban Board Integration
                  ProjectDetailsContainer(
                    icon: Icons.task_alt,
                    title: 'Tasks',
                    iconColor: Colors.green,
                    content: Container(
                      height: 450, // Set an appropriate height for the Kanban board
                      child: ProjectKanban(
                        projectId: widget.projectId,
                        projectColor: widget.color,
                        tasks: projectTasks,
                        onTaskStatusChanged: (taskId, newStatus) {
                          // Handle task status change and trigger confetti
                          _handleTaskStatusChange(taskId, newStatus);
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          floatingActionButton: ActionButton(
            label: 'Add Task',
            icon: Icons.add_task,
            backgroundColor: const Color(0xFF1E88E5), // Bright blue color
            scale: 1.2, // Slightly larger for better visibility
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
                    projectId: widget.projectId,
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
        ),
        
        // Enhanced confetti for completed tasks
        Align(
          alignment: Alignment.topCenter,
          child: ConfettiWidget(
            confettiController: _completedConfettiController,
            blastDirectionality: BlastDirectionality.directional,
            blastDirection: pi / 2, // straight down
            emissionFrequency: 0.05, // more particles
            numberOfParticles: 50, // increased number of particles
            maxBlastForce: 5,
            minBlastForce: 2,
            particleDrag: 0.05, // reduced drag for wider spread
            gravity: 0.2, // reduced gravity for slower fall
            maximumSize: const Size(12, 12), // larger particles
            minimumSize: const Size(5, 5),
            createParticlePath: drawStar, // star-shaped confetti
            // Create a party rainbow of colors
            colors: const [
              Color(0xFF1E88E5), // Blue
              Color(0xFF43A047), // Green
              Color(0xFFE53935), // Red
              Color(0xFFFFEB3B), // Yellow
              Color(0xFFAB47BC), // Purple
              Color(0xFFFF9800), // Orange
              Color(0xFF00ACC1), // Teal
              Color(0xFFEC407A), // Pink
            ],
            canvas: const Size(double.infinity, double.infinity), // Full screen canvas
            shouldLoop: false,
          ),
        ),
      ],
    );
  }
}