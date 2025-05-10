import 'package:flutter/material.dart';
import '../Objects/task.dart';

/// Utility functions for Task management
class TaskUtils {
  /// Format a task priority as a human-readable string with an icon
  static Widget formatTaskPriority(int priority) {
    IconData icon;
    Color color;
    
    switch (priority) {
      case 1:
        icon = Icons.low_priority;
        color = Colors.green;
        break;
      case 2:
        icon = Icons.low_priority;
        color = Colors.lightGreen;
        break;
      case 3:
        icon = Icons.flag;
        color = Colors.orange;
        break;
      case 4:
        icon = Icons.priority_high;
        color = Colors.deepOrange;
        break;
      case 5:
        icon = Icons.priority_high;
        color = Colors.red;
        break;
      default:
        icon = Icons.flag;
        color = Colors.blue;
    }
    
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: color, size: 16),
        const SizedBox(width: 4),
        Text("Priority $priority", style: TextStyle(color: color)),
      ],
    );
  }
  
  /// Calculate days remaining until a task is due
  static int calculateDaysRemaining(DateTime dueDate) {
    final today = DateTime.now();
    return dueDate.difference(today).inDays;
  }
  
  /// Format days remaining as a string with appropriate coloring
  static Widget formatDaysRemaining(DateTime dueDate) {
    final daysRemaining = calculateDaysRemaining(dueDate);
    
    Color textColor;
    String text;
    
    if (daysRemaining < 0) {
      textColor = Colors.red;
      text = "Overdue by ${-daysRemaining} day${-daysRemaining != 1 ? 's' : ''}";
    } else if (daysRemaining == 0) {
      textColor = Colors.red;
      text = "Due today";
    } else if (daysRemaining <= 2) {
      textColor = Colors.orange;
      text = "Due in $daysRemaining day${daysRemaining != 1 ? 's' : ''}";
    } else {
      textColor = Colors.green;
      text = "Due in $daysRemaining days";
    }
    
    return Text(text, style: TextStyle(color: textColor, fontWeight: FontWeight.bold));
  }
  
  /// Get color for a task status
  static Color getStatusColor(Status status) {
    switch (status) {
      case Status.todo:
        return Colors.grey;
      case Status.inProgress:
        return Colors.blue;
      case Status.completed:
        return Colors.green;
      default:
        return Colors.grey;
    }
  }
}