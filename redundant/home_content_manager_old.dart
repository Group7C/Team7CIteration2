import 'package:flutter/material.dart';
import '../contents/projects_list_content.dart';
import '../contents/groups_list_content.dart';
import '../contents/activity_tracker_content.dart';
import '../contents/deadline_manager_content.dart';
import '../contents/kanban_board_content.dart';
import '../../../services/api_service.dart';

/// Handles data and content for home screen bits [central point for all home widgets]
class HomeContentManager {
  /// Builds projects list content [shows active projects with progress]
  static Future<Widget> buildProjectsListContent({Function(ProjectItem)? onProjectTap}) async {
    final apiData = await ApiService.fetchUserProjects();
    
    final projects = apiData.map((data) => ProjectItem(
      name: data['title'] ?? data['name'] ?? 'Unnamed Project',
      memberCount: data['members']?.length ?? 0,
      progress: data['percentage'] ?? 0,
      id: data['id']?.toString() ?? '',
    )).toList();

    return ProjectsListContent(
      projects: projects,
      onProjectTap: onProjectTap,
    );
  }

  /// Builds groups list content [shows teams with member counts]
  static Future<Widget> buildGroupsListContent({Function(GroupItem)? onGroupTap}) async {
    final apiData = await ApiService.fetchUserGroups();
    
    final groups = apiData.map((data) => GroupItem(
      name: data['name'] ?? 'Unnamed Group',
      memberCount: data['member_count'] ?? 0,
      status: data['status'] ?? 'Active',
      id: data['id']?.toString() ?? '',
    )).toList();

    return GroupsListContent(
      groups: groups,
      onGroupTap: onGroupTap,
    );
  }

  /// Builds activity feed content [shows recent user actions chronologically]
  static Future<Widget> buildActivityTrackerContent() async {
    final apiData = await ApiService.fetchRecentActivity();
    
    final activities = apiData.map((data) => ActivityItem(
      description: data['description'] ?? 'Recent activity',
      timeAgo: _formatTimeAgo(data['timestamp']),
      icon: _getActivityIcon(data['type']),
      color: _getActivityColor(data['type']),
      id: data['id']?.toString() ?? '',
    )).toList();

    return ActivityTrackerContent(
      activities: activities,
    );
  }

  /// Builds deadline timeline content [shows upcoming due dates sorted by time]
  static Future<Widget> buildDeadlineManagerContent() async {
    final apiData = await ApiService.fetchUpcomingDeadlines();
    
    final deadlines = apiData.map((data) => DeadlineItem(
      title: data['title'] ?? 'Unnamed Task',
      project: data['project_name'] ?? 'Unknown Project',
      time: _formatDeadlineTime(data['due_date']),
      id: data['id']?.toString() ?? '',
      color: _getProjectColor(data['project_id']),
    )).toList();

    return DeadlineManagerContent(
      deadlines: deadlines,
    );
  }

  /// Builds kanban board content [shows task cards in status columns]
  static Future<Widget> buildKanbanBoardContent() async {
    final apiData = await ApiService.fetchUserTasks();
    
    final tasksByStatus = <String, List<TaskItem>>{};
    
    // Group tasks by status
    for (var taskData in apiData) {
      final status = taskData['status'] ?? 'to_do';
      final taskItem = TaskItem(
        title: taskData['title'] ?? 'Unnamed Task',
        project: taskData['project_name'] ?? 'Unknown Project',
        dueDate: _formatDueDate(taskData['due_date']),
        priority: taskData['priority'] ?? 'Medium',
        assignee: taskData['assignee_username'] ?? 'Unassigned',
        id: taskData['id']?.toString() ?? '',
      );
      
      if (!tasksByStatus.containsKey(status)) {
        tasksByStatus[status] = [];
      }
      tasksByStatus[status]!.add(taskItem);
    }
    
    final columns = {
      "To Do": KanbanColumn(
        tasks: tasksByStatus['todo'] ?? [],
        color: Colors.grey,
      ),
      "In Progress": KanbanColumn(
        tasks: tasksByStatus['in_progress'] ?? [],
        color: Colors.blue,
      ),
      "Review": KanbanColumn(
        tasks: tasksByStatus['review'] ?? [],
        color: Colors.amber,
      ),
      "Done": KanbanColumn(
        tasks: tasksByStatus['completed'] ?? [],
        color: Colors.green,
      ),
    };

    return KanbanBoardContent(
      columns: columns,
    );
  }
  
  // Helper methods for formatting data
  static String _formatTimeAgo(dynamic timestamp) {
    if (timestamp == null) return '';
    
    try {
      final date = DateTime.parse(timestamp.toString());
      final now = DateTime.now();
      final difference = now.difference(date);
      
      if (difference.inSeconds < 60) {
        return 'just now';
      } else if (difference.inMinutes < 60) {
        return '${difference.inMinutes} minute${difference.inMinutes != 1 ? 's' : ''} ago';
      } else if (difference.inHours < 24) {
        return '${difference.inHours} hour${difference.inHours != 1 ? 's' : ''} ago';
      } else if (difference.inDays < 7) {
        return '${difference.inDays} day${difference.inDays != 1 ? 's' : ''} ago';
      } else {
        return 'on ${date.day}/${date.month}/${date.year}';
      }
    } catch (e) {
      return '';
    }
  }
  
  static String _formatDeadlineTime(dynamic dueDate) {
    if (dueDate == null) return '';
    
    try {
      final date = DateTime.parse(dueDate.toString());
      final now = DateTime.now();
      
      if (date.year == now.year && date.month == now.month && date.day == now.day) {
        return 'Today';
      } else if (date.difference(now).inDays == 1) {
        return 'Tomorrow';
      } else {
        return '${_getDayName(date.weekday)}, ${date.day}/${date.month}';
      }
    } catch (e) {
      return '';
    }
  }
  
  static String _formatDueDate(dynamic dueDate) {
    if (dueDate == null) return '';
    
    try {
      final date = DateTime.parse(dueDate.toString());
      return '${_getMonthAbbr(date.month)} ${date.day}';
    } catch (e) {
      return '';
    }
  }
  
  static String _getDayName(int weekday) {
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return days[weekday - 1];
  }
  
  static String _getMonthAbbr(int month) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return months[month - 1];
  }
  
  static IconData _getActivityIcon(dynamic type) {
    switch (type) {
      case 'task_completed':
        return Icons.task_alt;
      case 'member_joined':
        return Icons.person_add;
      case 'design_updated':
        return Icons.design_services;
      case 'document_added':
        return Icons.file_present;
      case 'comment_added':
        return Icons.comment;
      default:
        return Icons.notifications;
    }
  }
  
  static Color _getActivityColor(dynamic type) {
    switch (type) {
      case 'task_completed':
        return Colors.green;
      case 'member_joined':
        return Colors.blue;
      case 'design_updated':
        return Colors.purple;
      case 'document_added':
        return Colors.amber;
      case 'comment_added':
        return Colors.teal;
      default:
        return Colors.grey;
    }
  }
  
  static Color _getProjectColor(dynamic projectId) {
    // You can define a color mapping for projects
    // For now, let's use a simple color scheme
    const colors = [
      Colors.blue,
      Colors.green,
      Colors.orange,
      Colors.purple,
      Colors.red,
      Colors.teal,
      Colors.indigo,
      Colors.pink,
    ];
    
    if (projectId == null) return Colors.grey;
    
    try {
      final id = int.parse(projectId.toString());
      return colors[id % colors.length];
    } catch (e) {
      return Colors.grey;
    }
  }
}
