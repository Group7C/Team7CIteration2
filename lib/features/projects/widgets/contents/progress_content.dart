import 'package:flutter/material.dart';

class ProgressContent extends StatelessWidget {
  final int completedTasks;
  final int totalTasks;
  final Color progressColor;
  // New parameter to track tasks in different statuses
  final List<Map<String, dynamic>>? tasks;
  
  const ProgressContent({
    Key? key,
    required this.completedTasks,
    required this.totalTasks,
    required this.progressColor,
    this.tasks,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final progress = totalTasks > 0 ? completedTasks / totalTasks : 0.0;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 12),
        // Task count with percentage
        Container(
          alignment: Alignment.center,
          child: Column(
            children: [
              Text(
                '${(progress * 100).toInt()}%',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 28,
                  color: progress > 0 ? progressColor : Colors.grey,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '$completedTasks of $totalTasks tasks completed',
                style: TextStyle(
                  color: Colors.grey[700],
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
        
        const SizedBox(height: 12),
        
        // Status indicator
        Center(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: _getStatusColor(tasks).withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: _getStatusColor(tasks).withOpacity(0.3)),
            ),
            child: Text(
              _getStatusText(tasks),
              style: TextStyle(
                color: _getStatusColor(tasks),
                fontWeight: FontWeight.w500,
                fontSize: 14,
              ),
            ),
          ),
        ),
      ],
    );
  }
  
  // Updated to use tasks list instead of progress
  Color _getStatusColor(List<Map<String, dynamic>>? tasks) {
    if (tasks == null || tasks.isEmpty) {
      return Colors.grey; // No tasks
    }
    
    int todoCount = 0;
    int inProgressCount = 0;
    int completedCount = 0;
    
    for (var task in tasks) {
      final status = task['status']?.toString().toLowerCase() ?? '';
      if (status == 'completed') {
        completedCount++;
      } else if (status == 'in_progress') {
        inProgressCount++;
      } else if (status == 'todo') {
        todoCount++;
      }
    }
    
    // All tasks completed
    if (completedCount == tasks.length && tasks.isNotEmpty) {
      return Colors.green;
    }
    
    // At least one task in progress
    if (inProgressCount > 0) {
      return Colors.blue;
    }
    
    // All tasks in todo or no tasks at all
    return Colors.red;
  }
  
  // Updated to implement the requested statuses
  String _getStatusText(List<Map<String, dynamic>>? tasks) {
    if (tasks == null || tasks.isEmpty) {
      return 'No Tasks';
    }
    
    int todoCount = 0;
    int inProgressCount = 0;
    int completedCount = 0;
    
    for (var task in tasks) {
      final status = task['status']?.toString().toLowerCase() ?? '';
      if (status == 'completed') {
        completedCount++;
      } else if (status == 'in_progress') {
        inProgressCount++;
      } else if (status == 'todo') {
        todoCount++;
      }
    }
    
    // All tasks completed
    if (completedCount == tasks.length && tasks.isNotEmpty) {
      return 'Complete';
    }
    
    // At least one task in progress
    if (inProgressCount > 0) {
      return 'In Progress';
    }
    
    // All tasks in todo or no tasks at all
    return 'Not Started';
  }
}
