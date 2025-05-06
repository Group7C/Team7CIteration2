import 'package:flutter/material.dart';

// Class for storing member contribution data [metrics per person]
class MemberContribution {
  final String username;
  final int totalTasks;        // All tasks assigned to member
  final int completedTasks;    // How many tasks they've finished
  final bool isOwner;          // Whether they own the project
  final String role;           // Role/permission level obv
  final double taskWeight;     // The weighted contribution from tasks (0-90%)
  final double attendanceWeight; // The weighted contribution from attendance (0-10%)
  
  MemberContribution({
    required this.username,
    required this.totalTasks,
    required this.completedTasks,
    required this.isOwner,
    required this.role,
    this.taskWeight = 0.0,
    this.attendanceWeight = 0.0,
  });
  
  // Calculate completion percentage [0-100]
  double getCompletionPercentage() {
    if (totalTasks == 0) return 0.0;
    return (completedTasks / totalTasks) * 100;
  }
  
  // Get simple progress as fraction [0.0-1.0 for progress bars]
  double getProgressFraction() {
    if (totalTasks == 0) return 0.0;
    return completedTasks / totalTasks;
  }
  
  // Get colour based on completion [for visual indicators]
  static Color getProgressColour(double percentage, {bool useOpacity = false, double opacity = 0.1}) {
    final baseColour = percentage >= 75 ? Colors.green :
                     percentage >= 50 ? Colors.blue :
                     percentage >= 25 ? Colors.orange :
                     Colors.red;
                     
    return useOpacity ? baseColour.withOpacity(opacity) : baseColour;
  }
  
  // Get total weighted contribution (tasks + attendance)
  double getTotalContribution() {
    return taskWeight + attendanceWeight;
  }
}

// Container for full report [holds all contributions]
class ContributionReport {
  final Map<String, MemberContribution> memberContributions;
  final DateTime generatedAt;
  
  ContributionReport({
    required this.memberContributions,
    DateTime? generatedAt,
  }) : generatedAt = generatedAt ?? DateTime.now();
  
  // Find top contributor [person with highest completion]
  MemberContribution? getTopContributor() {
    if (memberContributions.isEmpty) return null;
    
    return memberContributions.values.reduce((curr, next) {
      return curr.getCompletionPercentage() > next.getCompletionPercentage() ? curr : next;
    });
  }
  
  // Get overall project completion [avg of all members]
  double getOverallCompletion() {
    if (memberContributions.isEmpty) return 0.0;
    
    final totalPercentages = memberContributions.values
        .map((c) => c.getCompletionPercentage())
        .reduce((a, b) => a + b);
        
    return totalPercentages / memberContributions.length;
  }
}