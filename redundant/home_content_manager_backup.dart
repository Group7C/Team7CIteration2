import 'package:flutter/material.dart';
import '../contents/projects_list_content.dart';
import '../contents/groups_list_content.dart';
import '../contents/activity_tracker_content.dart';
import '../contents/deadline_manager_content.dart';
import '../contents/kanban_board_content.dart';

/// Handles data and content for home screen bits [central point for all home widgets]
class HomeContentManager {
  /// Builds projects list content [shows active projects with progress]
  static Widget buildProjectsListContent({Function(ProjectItem)? onProjectTap}) {
    // Mock data - will fetch from DB when setup
    final projects = [
      ProjectItem(
        name: "Team Project",
        memberCount: 5,
        progress: 75,
        id: "1",
      ),
      ProjectItem(
        name: "Research Paper",
        memberCount: 3,
        progress: 45,
        id: "2",
      ),
      ProjectItem(
        name: "UI Design",
        memberCount: 2,
        progress: 10,
        id: "3",
      ),
    ];

    return ProjectsListContent(
      projects: projects,
      onProjectTap: onProjectTap,
    );
  }

  /// Builds groups list content [shows teams with member counts]
  static Widget buildGroupsListContent({Function(GroupItem)? onGroupTap}) {
    // Mock data - will fetch from DB when setup
    final groups = [
      GroupItem(
        name: "Development Team",
        memberCount: 8,
        status: "Active",
        id: "1",
      ),
      GroupItem(
        name: "Design Team",
        memberCount: 5,
        status: "Active",
        id: "2",
      ),
      GroupItem(
        name: "Research Team",
        memberCount: 3,
        status: "Inactive",
        id: "3",
      ),
    ];

    return GroupsListContent(
      groups: groups,
      onGroupTap: onGroupTap,
    );
  }

  /// Builds activity feed content [shows recent user actions chronologically]
  static Widget buildActivityTrackerContent() {
    // Mock data - will pull from activity log when DB setup
    final activities = [
      ActivityItem(
        description: "John completed a task",
        timeAgo: "1 hour ago",
        icon: Icons.task_alt,
        color: Colors.green,
        id: "1",
      ),
      ActivityItem(
        description: "Sarah joined the project",
        timeAgo: "2 hours ago",
        icon: Icons.person_add,
        color: Colors.blue,
        id: "2",
      ),
      ActivityItem(
        description: "Mike updated the design",
        timeAgo: "Yesterday",
        icon: Icons.design_services,
        color: Colors.purple,
        id: "3",
      ),
      ActivityItem(
        description: "Emma added a new document",
        timeAgo: "Yesterday",
        icon: Icons.file_present,
        color: Colors.amber,
        id: "4",
      ),
      ActivityItem(
        description: "Alex commented on a task",
        timeAgo: "2 days ago",
        icon: Icons.comment,
        color: Colors.teal,
        id: "5",
      ),
    ];

    return ActivityTrackerContent(
      activities: activities,
    );
  }

  /// Builds deadline timeline content [shows upcoming due dates sorted by time]
  static Widget buildDeadlineManagerContent() {
    // Project colour mapping for visual consistency
    final Map<String, Color> projectColors = {
      "Team Project": Colors.green,
      "Backend Development": Colors.purple,
      "Marketing Campaign": Colors.orange,
      "UI Design": Colors.amber,
    };
    
    // Mock data - will pull from proper calendar when DB setup
    final deadlines = [
      DeadlineItem(
        title: "Submit Project Proposal",
        project: "Team Project",
        time: "Today, 2:00 PM",
        id: "1",
        color: projectColors["Team Project"]!,
      ),
      DeadlineItem(
        title: "Review Pull Request",
        project: "Backend Development",
        time: "Today, 5:00 PM",
        id: "2",
        color: projectColors["Backend Development"]!,
      ),
      DeadlineItem(
        title: "Team Meeting",
        project: "Team Project",
        time: "Tomorrow, 10:00 AM",
        id: "3",
        color: projectColors["Team Project"]!,
      ),
      DeadlineItem(
        title: "Client Call",
        project: "Marketing Campaign",
        time: "Tomorrow, 2:30 PM",
        id: "4",
        color: projectColors["Marketing Campaign"]!,
      ),
      DeadlineItem(
        title: "Complete Frontend Tasks",
        project: "UI Design",
        time: "Friday, 3:00 PM",
        id: "5",
        color: projectColors["UI Design"]!,
      ),
      DeadlineItem(
        title: "Database Implementation",
        project: "Backend Development",
        time: "Saturday, 12:00 PM",
        id: "6",
        color: projectColors["Backend Development"]!,
      ),
    ];

    return DeadlineManagerContent(
      deadlines: deadlines,
    );
  }

  /// Builds kanban board content [shows task cards in status columns]
  static Widget buildKanbanBoardContent() {
    // Mock data - will sync with task DB when setup
    final columns = {
      "To Do": KanbanColumn(
        tasks: [
          TaskItem(
            title: "Research API options",
            project: "Backend Development",
            dueDate: "Apr 15",
            priority: "High",
            assignee: "Me",
            id: "1",
          ),
          TaskItem(
            title: "Design database schema",
            project: "Backend Development",
            dueDate: "Apr 20",
            priority: "Medium",
            assignee: "Me",
            id: "2",
          ),
        ],
        color: Colors.grey,
      ),
      "In Progress": KanbanColumn(
        tasks: [
          TaskItem(
            title: "Create login page",
            project: "Frontend Development",
            dueDate: "Apr 12",
            priority: "High",
            assignee: "Me",
            id: "3",
          ),
        ],
        color: Colors.blue,
      ),
      "Review": KanbanColumn(
        tasks: [
          TaskItem(
            title: "Update README file",
            project: "Documentation",
            dueDate: "Apr 10",
            priority: "Low",
            assignee: "Me",
            id: "4",
          ),
        ],
        color: Colors.amber,
      ),
      "Done": KanbanColumn(
        tasks: [
          TaskItem(
            title: "Setup project repository",
            project: "DevOps",
            dueDate: "Apr 5",
            priority: "Medium",
            assignee: "Me",
            id: "5",
          ),
          TaskItem(
            title: "Define project requirements",
            project: "Planning",
            dueDate: "Apr 3",
            priority: "High",
            assignee: "Me",
            id: "6",
          ),
        ],
        color: Colors.green,
      ),
    };

    return KanbanBoardContent(
      columns: columns,
    );
  }

  /// TODO: Set up proper data fetching 
  /// Example for future DB integration:
  /// static Future<List<ProjectItem>> fetchProjects() async {
  ///   // DB query goes here - will replace mocks
  ///   return [];
  /// }
}
