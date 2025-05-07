import 'package:flutter/material.dart';
import '../../../features/common/services/task_service.dart';
import '../../../features/common/models/project_model.dart';
import '../../../features/common/models/task_model.dart';

enum TaskStatus { to_do, in_progress, complete }
enum NotificationFrequency { daily, weekly }

class TaskFormController {
  // Form controllers
  final titleController = TextEditingController();
  final descriptionController = TextEditingController();
  final priorityController = TextEditingController();
  final endDateController = TextEditingController();
  final tagController = TextEditingController();
  final weightingController = TextEditingController();
  
  // Form key for validation
  final formKey = GlobalKey<FormState>();
  
  // Form state
  final List<String> tags = [];
  final Map<int, String> assignedMembers = {}; // This now stores user_id -> role instead of members_id -> role
  String? selectedParent;
  NotificationFrequency notificationFrequency = NotificationFrequency.daily;
  
  // Focus nodes
  final titleFocusNode = FocusNode();
  final descriptionFocusNode = FocusNode();
  final dateFocusNode = FocusNode();
  final tagFocusNode = FocusNode();
  final weightingFocusNode = FocusNode();
  final priorityFocusNode = FocusNode();
  
  // Helper methods
  void addTag(String tag) {
    if (tag.trim().isNotEmpty && !tags.contains(tag.trim())) {
      tags.add(tag.trim());
    }
  }
  
  void removeTag(String tag) {
    tags.remove(tag);
  }
  
  void assignMember(int memberId, String role) {
    assignedMembers[memberId] = role;
  }
  
  void removeMember(int memberId) {
    assignedMembers.remove(memberId);
  }
  
  // Clear form data
  void clearForm() {
    titleController.clear();
    descriptionController.clear();
    priorityController.text = "1";
    endDateController.clear();
    tagController.clear();
    weightingController.clear();
    tags.clear();
    assignedMembers.clear();
    notificationFrequency = NotificationFrequency.daily;
    selectedParent = null;
  }
  
  // Submit task
  Future<Map<String, dynamic>> submitTask(int projectId) async {
    if (!formKey.currentState!.validate()) {
      return {'success': false, 'task': null};
    }
    
    try {
      // Ensure at least one member is assigned
      if (assignedMembers.isEmpty) {
        return {'success': false, 'task': null, 'error': 'At least one member must be assigned to the task'};
      }
      
      // Convert user IDs to comma-separated string for API
      final userIds = assignedMembers.keys.join(',');
      
      // Create task using task service with the new userIds parameter
      final taskId = await TaskService.createTask(
        projectId: projectId,
        taskName: titleController.text,
        description: descriptionController.text,
        priority: int.tryParse(priorityController.text) ?? 1,
        startDate: DateTime.now(), // Current date as start date
        endDate: DateTime.parse(endDateController.text),
        tags: tags.isNotEmpty ? tags.first : null, // API currently supports one tag
        notificationFrequency: notificationFrequency == NotificationFrequency.daily ? 'Daily' : 'Weekly',
        status: 'to_do', // Default status for new tasks
        weighting: int.tryParse(weightingController.text),
        userIds: userIds, // Use userIds instead of membersIds
      );
      
      // Create task member objects from assigned members
      List<TaskMember> taskMembers = assignedMembers.keys.map((memberId) {
        return TaskMember(
          membersId: memberId,
          userId: 0, // We don't have this information here
          username: '' // We don't have this information here
        );
      }).toList();
      
      // Create a Task object with the data
      final task = Task(
        taskId: taskId,
        taskName: titleController.text,
        description: descriptionController.text,
        priority: int.tryParse(priorityController.text) ?? 1,
        startDate: DateTime.now(),
        endDate: DateTime.parse(endDateController.text),
        tags: tags.isNotEmpty ? tags.first : null,
        notificationFrequency: notificationFrequency == NotificationFrequency.daily ? 'Daily' : 'Weekly',
        status: 'to_do',
        weighting: int.tryParse(weightingController.text),
        projectUid: projectId,
        projectName: '', // We don't have this info here
        assignedMembers: taskMembers, // Set the task members
      );
      
      // Reset form after successful submission
      clearForm();
      return {'success': true, 'task': task};
    } catch (e) {
      print('Error submitting task: $e');
      return {'success': false, 'task': null, 'error': e.toString()};
    }
  }
  
  // Dispose resources
  void dispose() {
    titleController.dispose();
    descriptionController.dispose();
    priorityController.dispose();
    endDateController.dispose();
    tagController.dispose();
    weightingController.dispose();
    
    titleFocusNode.dispose();
    descriptionFocusNode.dispose();
    dateFocusNode.dispose();
    tagFocusNode.dispose();
    weightingFocusNode.dispose();
    priorityFocusNode.dispose();
  }
}