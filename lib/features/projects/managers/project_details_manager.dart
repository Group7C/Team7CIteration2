import 'package:flutter/material.dart';
import '../models/project.dart';
import '../widgets/contents/deadline_content.dart';
import '../widgets/contents/meetings_content.dart';
import '../widgets/contents/analysis_content.dart';
import '../widgets/contents/progress_content.dart';
import '../widgets/contents/description_content.dart';
import '../widgets/contents/team_members_content.dart';
import '../widgets/contents/tasks_list_content.dart';

/// Controls data flow for project details widgets [central manager for project screens]
class ProjectDetailsManager {
  /// Builds deadline widget [shows project end date and countdown]
  static Widget buildDeadlineContent(DateTime deadline) {
    return DeadlineContent(deadline: deadline);
  }

  /// Builds meetings timeline [shows past and upcoming team calls]
  static Widget buildMeetingsContent({String? lastMeetingDate, String? nextMeetingDate}) {
    return MeetingsContent(
      lastMeetingDate: lastMeetingDate ?? 'Not recorded',
      nextMeetingDate: nextMeetingDate,
    );
  }

  /// Builds analytics dashboard [shows key project metrics and charts]
  static Widget buildAnalysisContent(int completedTasks, int totalTasks) {
    return AnalysisContent(
      completedTasks: completedTasks,
      totalTasks: totalTasks,
    );
  }

  /// Builds progress indicator [shows completion percentage visually]
  static Widget buildProgressContent(
    int completedTasks, 
    int totalTasks, 
    Color progressColor, {
    List<Map<String, dynamic>>? tasks,
  }) {
    return ProgressContent(
      completedTasks: completedTasks,
      totalTasks: totalTasks,
      progressColor: progressColor,
      tasks: tasks,
    );
  }

  /// Builds description area [shows formatted project overview text]
  static Widget buildDescriptionContent(String description) {
    return DescriptionContent(description: description);
  }

  /// Builds team roster [shows members and their roles]
  static Widget buildTeamMembersContent(int members) {
    return TeamMembersContent(members: members);
  }

  /// Builds tasks list [shows project-specific work items]
  static Widget buildTasksListContent({String? projectId, Project? project}) {
    return TasksListContent(projectId: projectId, project: project);
  }

  /// TODO: Connect to proper data source
  /// Future DB integration example:
  /// static Future<List<Meeting>> fetchMeetings(String projectId) async {
  ///   // DB query goes here - will replace hardcoded data
  ///   return [];
  /// }
}
