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
  static Future<Widget> buildProjectsListContent(BuildContext context, {Function(ProjectItem)? onProjectTap}) async {
    print('\n=== BUILDING PROJECTS CONTENT ===');
    final apiData = await ApiService.fetchUserProjects(context);
    
    final projects = apiData.map((data) => ProjectItem(
      name: data['title'] ?? data['name'] ?? 'Unnamed Project',
      memberCount: data['members'] ?? 0,
      progress: data['percentage'] ?? 0,
      id: data['id'] ?? '',
    )).toList();

    print('Converted to ${projects.length} ProjectItems');
    print('=== PROJECTS CONTENT BUILT ===\n');

    return ProjectsListContent(
      projects: projects,
      onProjectTap: onProjectTap,
    );
  }

  /// Builds groups list content [shows task collaboration groups]
  static Future<Widget> buildGroupsListContent(BuildContext context, {Function(GroupItem)? onGroupTap}) async {
    print('\n=== BUILDING GROUPS CONTENT ===');
    final apiData = await ApiService.fetchUserGroups(context);
    
    final groups = apiData.map((data) => GroupItem(
      name: data['name'] ?? 'Unnamed Group',
      memberCount: data['member_count'] ?? 0,
      status: data['status'] ?? 'Active',
      id: data['id']?.toString() ?? '',
      projectId: data['project_id']?.toString() ?? '',
      projectName: data['project_name']?.toString() ?? '',
      taskTitle: data['task_title']?.toString() ?? '',
      members: data['members'] as Map<String, dynamic>?,
    )).toList();

    print('Converted to ${groups.length} GroupItems');
    print('=== GROUPS CONTENT BUILT ===\n');

    return GroupsListContent(
      groups: groups,
      onGroupTap: onGroupTap,
    );
  }

  /// Builds activity feed content [shows recent user actions chronologically]
  static Future<Widget> buildActivityTrackerContent(BuildContext context) async {
    print('\n=== BUILDING ACTIVITY CONTENT ===');
    final apiData = await ApiService.fetchRecentActivity(context);
    
    final activities = apiData.map((data) => ActivityItem(
      description: data['description'] ?? 'Recent activity',
      timeAgo: _formatTimeAgo(data['timestamp']),
      icon: _getActivityIcon(data['type']),
      color: _getActivityColor(data['type']),
      id: data['id']?.toString() ?? '',
    )).toList();

    print('Converted to ${activities.length} ActivityItems');
    print('=== ACTIVITY CONTENT BUILT ===\n');

    return ActivityTrackerContent(
      activities: activities,
    );
  }

  /// Builds deadline timeline content [shows upcoming due dates sorted by time]
  static Future<Widget> buildDeadlineManagerContent(BuildContext context, {Function(DeadlineItem)? onDeadlineTap}) async {
    print('\n=== BUILDING DEADLINES CONTENT ===');
    final apiData = await ApiService.fetchUpcomingDeadlines(context);
    
    final deadlines = apiData.map((data) => DeadlineItem(
      title: data['title'] ?? 'Unnamed Task',
      project: data['project_name'] ?? 'Unknown Project',
      time: _formatDeadlineTime(data['due_date']),
      id: data['id']?.toString() ?? '',
      projectId: data['project_id']?.toString() ?? '',
      color: _getProjectColor(data['project_id']),
    )).toList();

    print('Converted to ${deadlines.length} DeadlineItems');
    print('=== DEADLINES CONTENT BUILT ===\n');

    return DeadlineManagerContent(
      deadlines: deadlines,
      onDeadlineTap: onDeadlineTap,
    );
  }

  /// Builds kanban board content [shows task cards in status columns]
  static Future<Widget> buildKanbanBoardContent(BuildContext context) async {
    print('\n=== BUILDING KANBAN CONTENT ===');
    
    // Important fix: Don't try to pre-process the tasks here
    // The UserKanbanReal will fetch and process tasks itself
    
    // Simply return the KanbanBoardContent wrapper which contains UserKanbanReal
    return const KanbanBoardContent();
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