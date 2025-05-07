import 'package:flutter/material.dart';
import '../../../features/common/services/task_service.dart';
import '../../../features/common/models/task_model.dart';
import 'task_form_controller.dart';

class TaskEditController extends TaskFormController {
  // Additional property to track the task being edited
  final Task task;
  
  // Track original member IDs to identify removals
  final Set<int> originalMemberIds = {};
  
  // Constructor that takes an existing task
  TaskEditController(this.task) {
    // Initialize form fields with task data
    _initializeFields();
  }
  
  // Method to initialize form fields from the task
  void _initializeFields() {
    // Set basic task fields
    titleController.text = task.taskName;
    descriptionController.text = task.description ?? '';
    priorityController.text = task.priority.toString();
    endDateController.text = task.endDate.toIso8601String().split('T')[0];
    weightingController.text = task.weighting?.toString() ?? '';
    
    // Set notification frequency
    notificationFrequency = task.notificationFrequency.toLowerCase() == 'daily' 
        ? NotificationFrequency.daily 
        : NotificationFrequency.weekly;
    
    // Set tags (if available)
    if (task.tags != null && task.tags!.isNotEmpty) {
      tags.add(task.tags!);
    }
    
    // Set assigned members and track original member IDs
    for (var member in task.assignedMembers) {
      // Assume 'Editor' role for existing members as that data might not be available in the task model
      // In a real system, you might want to fetch the actual roles
      assignedMembers[member.membersId] = 'Editor';
      
      // Store original member ID for tracking removals
      originalMemberIds.add(member.membersId);
    }
  }
  
  // Override submit method to update task instead of creating a new one
  @override
  Future<Map<String, dynamic>> submitTask(int projectId) async {
    if (!formKey.currentState!.validate()) {
      return {'success': false, 'task': null};
    }
    
    try {
      // Convert member IDs to comma-separated string for API
      final membersIds = assignedMembers.keys.join(',');
      
      // Determine which members were removed by comparing original members to current members
      final currentMemberIds = assignedMembers.keys.toSet();
      final removedMemberIds = originalMemberIds.difference(currentMemberIds);
      final removeMembersIds = removedMemberIds.isNotEmpty ? removedMemberIds.join(',') : null;
      
      // Update task using task service
      final success = await TaskService.updateTask(
        taskId: task.taskId,
        taskName: titleController.text,
        description: descriptionController.text,
        priority: int.tryParse(priorityController.text) ?? 1,
        // We'll keep the existing start date rather than setting it to now
        endDate: DateTime.parse(endDateController.text),
        tags: tags.isNotEmpty ? tags.first : null, // API currently supports one tag
        notificationFrequency: notificationFrequency == NotificationFrequency.daily ? 'Daily' : 'Weekly',
        // Don't change status - maintain the existing one
        weighting: int.tryParse(weightingController.text),
        membersIds: membersIds,
        removeMembersIds: removeMembersIds,
      );
      
      // Create updated Task object
      final updatedTask = Task(
        taskId: task.taskId,
        taskName: titleController.text,
        description: descriptionController.text,
        priority: int.tryParse(priorityController.text) ?? 1,
        startDate: task.startDate,
        endDate: DateTime.parse(endDateController.text),
        tags: tags.isNotEmpty ? tags.first : null,
        notificationFrequency: notificationFrequency == NotificationFrequency.daily ? 'Daily' : 'Weekly',
        status: task.status,
        weighting: int.tryParse(weightingController.text),
        projectUid: task.projectUid,
        projectName: task.projectName,
        assignedMembers: task.assignedMembers, // This doesn't reflect potential changes in members
      );
      
      return {'success': success, 'task': updatedTask};
    } catch (e) {
      print('Error updating task: $e');
      return {'success': false, 'task': null};
    }
  }
}