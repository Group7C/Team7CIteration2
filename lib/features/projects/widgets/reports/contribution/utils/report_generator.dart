import 'package:flutter/material.dart';
import '../../../../../../features/projects/models/project.dart';
import '../models/member_contribution.dart';

// Mock data structure for tasks
class _MockTask {
  final String id;
  final String title;
  final double weight; // Weight as percentage of project (0-100)
  final List<ProjectMember> assignedMembers;
  final bool completed;
  
  _MockTask({
    required this.id,
    required this.title,
    required this.weight,
    required this.assignedMembers,
    this.completed = false,
  });
}

// Helper class to generate contribution data [separate data logic]
class ReportGenerator {
  // Generate project contribution report with the 90/10 algorithm
  static Future<ContributionReport> generateReport(Project project) async {
    // Will call API eventually
    // Just making sample data for testing
    
    final Map<String, MemberContribution> contributions = {};
    
    // MOCK DATA: Create some tasks with weights (total should add up to 100)
    final mockTasks = _generateMockTasks(project);
    
    // Make contribution data for each team member
    for (final member in project.members) {
      // Calculate task contribution (90% of total score)
      final taskContribution = _calculateTaskContribution(member, mockTasks);
      final weightedTaskContribution = taskContribution * 0.9; // 90% weight for tasks
      
      // Calculate mock attendance contribution (10% of total score)
      final attendanceContribution = _generateMockAttendanceContribution(member);
      final weightedAttendanceContribution = attendanceContribution * 0.1; // 10% weight for attendance
      
      // Some reasonable task data that aligns with our contribution calculation
      final totalTasks = _countMemberTasks(member, mockTasks);
      final completedTasks = (totalTasks * 0.7).round(); // Assume 70% completion rate
      
      contributions[member.username] = MemberContribution(
        username: member.username,
        totalTasks: totalTasks,
        completedTasks: completedTasks,
        isOwner: member.isOwner,
        role: member.isOwner ? 'Owner' : 'Member',
        taskWeight: weightedTaskContribution,
        attendanceWeight: weightedAttendanceContribution,
      );
    }
    
    return ContributionReport(memberContributions: contributions);
  }
  
  // Export report to file [placeholder]
  static Future<bool> exportReport(ContributionReport report, Project project) async {
    // Need to add PDF/CSV export here
    // Just pretending success for now
    await Future.delayed(const Duration(milliseconds: 500));
    return true;
  }
  
  // Calculate contribution metrics by member [combining task and attendance metrics]
  static Map<String, double> calculateContributionWeights(ContributionReport report) {
    final Map<String, double> weights = {};
    
    // Use the total weighted contribution for each member
    for (final contribution in report.memberContributions.values) {
      weights[contribution.username] = contribution.getTotalContribution();
    }
    
    return weights;
  }
  
  // MOCK DATA GENERATION
  // ---------------------
  
  // Generate mock tasks with weights that add up to 100%
  static List<_MockTask> _generateMockTasks(Project project) {
    final tasks = <_MockTask>[];
    final members = project.members;
    double remainingWeight = 100.0;
    
    // Create 5 tasks with varying weights
    for (int i = 0; i < 5; i++) {
      // Last task gets remaining weight to ensure sum is exactly 100
      final weight = i == 4 ? remainingWeight : 10.0 + (i * 5.0);
      remainingWeight -= weight;
      
      // Assign 1-3 random members to each task
      final assignedMembers = <ProjectMember>[];
      final assigneeCount = 1 + (i % 3); // 1, 2 or 3 assignees
      
      for (int j = 0; j < assigneeCount; j++) {
        // Pick members in a somewhat distributed manner
        final memberIndex = (i + j) % members.length;
        assignedMembers.add(members[memberIndex]);
      }
      
      tasks.add(_MockTask(
        id: 'task-$i',
        title: 'Task ${i + 1}',
        weight: weight,
        assignedMembers: assignedMembers,
        completed: i < 3, // First 3 tasks are completed
      ));
    }
    
    return tasks;
  }
  
  // Generate mock attendance contribution (out of 100%)
  static double _generateMockAttendanceContribution(ProjectMember member) {
    // Owners tend to have better attendance
    final baseAttendance = member.isOwner ? 80.0 : 60.0;
    
    // Add some variation based on username hash
    final variation = (member.username.hashCode % 20) - 10.0;
    
    // Return percentage clamped between 0-100
    return (baseAttendance + variation).clamp(0.0, 100.0);
  }
  
  // Calculate task contribution (out of 100%)
  static double _calculateTaskContribution(ProjectMember member, List<_MockTask> tasks) {
    double contribution = 0.0;
    
    for (final task in tasks) {
      // Check if member is assigned to this task
      if (task.assignedMembers.any((m) => m.id == member.id)) {
        // Get task weight and divide by number of assigned members
        contribution += task.weight / task.assignedMembers.length;
      }
    }
    
    return contribution;
  }
  
  // Count how many tasks a member is assigned to
  static int _countMemberTasks(ProjectMember member, List<_MockTask> tasks) {
    return tasks.where((task) => 
      task.assignedMembers.any((m) => m.id == member.id)
    ).length;
  }
}