// Utilities for handling drag and drop operations in the kanban board
import 'package:flutter/material.dart';
import '../models/kanban_task.dart';

class DragDropHandler {
  // Handle task movement between columns
  static Future<bool> handleTaskStatusChange({
    required BuildContext context,
    required String taskId,
    required String newStatus,
    required Function(KanbanTask) updateUICallback,
    required Function(String, String) updateTaskFunction,
  }) async {
    debugPrint('Moving task $taskId to status: $newStatus');
    
    try {
      // Update status using the provided update function
      final success = await updateTaskFunction(taskId, newStatus);
      return success;
    } catch (e) {
      debugPrint('Error updating task status: $e');
      return false;
    }
  }
  
  // Create feedback widget for dragging
  static Widget createDragFeedback({
    required BuildContext context,
    required Widget child,
    double widthFactor = 0.3,
  }) {
    return SizedBox(
      width: MediaQuery.of(context).size.width * widthFactor,
      child: child,
    );
  }
  
  // Create faded placeholder for original position
  static Widget createDragPlaceholder({
    required Widget child,
    double opacity = 0.3,
  }) {
    return Opacity(
      opacity: opacity,
      child: child,
    );
  }
}