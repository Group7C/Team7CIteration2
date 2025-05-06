// Utilities for converting between Task and KanbanTask models
import 'package:flutter/material.dart';
import '../../../../Objects/task.dart';
import '../models/kanban_task.dart';

class TaskConverter {
  // Convert a Task to a KanbanTask for display in the kanban board
  static KanbanTask fromTask({
    required Task task,
    required String currentUserId,
    String? username,
    Color? projectColour,
  }) {
    // Figure out the project ID from the parent project string
    final projectId = task.parentProject ?? 'unknown';
    
    // Get assignee name - prefer actual assignees, fallback to username param
    String assigneeName;
    String assigneeId;
    
    if (task.members.isNotEmpty) {
      // Use first member if available
      assigneeName = task.members.keys.first;
      // Default to current user ID if we can't determine
      assigneeId = currentUserId;
    } else {
      // Fall back to username param or "Unassigned"
      assigneeName = username ?? "Unassigned";
      assigneeId = currentUserId;
    }
    
    // Use provided colour or generate one based on project ID
    final colour = projectColour ?? _getProjectColour(projectId);
    
    // Determine task status (adding this field to our Task model)
    // For this implementation, we'll default to 'todo' if not set
    String status = 'todo';
    
    return KanbanTask(
      id: task.title, // Using title as ID since our Task model doesn't have an ID field
      title: task.title,
      description: task.description,
      dueDate: task.endDate,
      status: status, // 'todo', 'in_progress', or 'completed'
      projectId: projectId,
      projectName: task.parentProject ?? "No Project",
      assigneeId: assigneeId,
      assigneeName: assigneeName,
      projectColour: colour,
    );
  }
  
  // Generate a consistent colour based on project ID
  static Color _getProjectColour(String projectId) {
    // Create a hash of the string
    final hash = projectId.hashCode.abs();
    
    // Use the hash to select from the primaries list
    return Colors.primaries[hash % Colors.primaries.length];
  }
  
  // Group tasks by status for the kanban board
  static Map<String, List<KanbanTask>> groupTasksByStatus(List<KanbanTask> tasks) {
    final result = {
      'todo': <KanbanTask>[],
      'in_progress': <KanbanTask>[],
      'completed': <KanbanTask>[],
    };
    
    for (final task in tasks) {
      if (result.containsKey(task.status)) {
        result[task.status]!.add(task);
      } else {
        // Default to todo if status isn't recognized
        result['todo']!.add(task);
      }
    }
    
    return result;
  }
}