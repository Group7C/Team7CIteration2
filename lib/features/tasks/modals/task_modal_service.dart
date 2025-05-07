import 'package:flutter/material.dart';
import '../widgets/task_form_widget.dart';
import '../widgets/task_edit_widget.dart';
import '../../../features/common/modals/large_modal.dart';
import '../../../features/common/models/project_model.dart';
import '../../../features/common/models/task_model.dart';
import '../../../features/common/services/task_service.dart';

class TaskModalService {
  /// Shows the task creation modal using the LargeModal component
  static Future<void> showAddTaskModal({
    required BuildContext context,
    required int projectId,
    required List<ProjectMember> members,
    Function(Task)? onTaskCreated,
  }) {
    return LargeModal.show(
      context: context,
      title: 'Add New Task',
      subtitle: 'Create a task for this project',
      content: [
        TaskFormWidget(
          projectId: projectId,
          members: members,
          onSubmitSuccess: onTaskCreated,
        ),
      ],
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel', style: TextStyle(color: Colors.white70)),
        ),
      ],
    );
  }
  
  /// Shows the task edit modal using the LargeModal component
  static Future<void> showEditTaskModal({
    required BuildContext context,
    required int taskId,
    required int projectId,
    required List<ProjectMember> members,
    VoidCallback? onTaskUpdated,
  }) async {
    try {
      // Show loading indicator
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (ctx) => const Center(child: CircularProgressIndicator()),
      );
      
      // Fetch task details from the backend
      final List<Task> projectTasks = await TaskService.getTasksByProject(projectId);
      
      // Find the task in the list
      Task? taskToEdit;
      for (var task in projectTasks) {
        if (task.taskId == taskId) {
          taskToEdit = task;
          break;
        }
      }
      
      // Close loading indicator
      Navigator.of(context).pop();
      
      if (taskToEdit == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Task not found')),
        );
        return;
      }
      
      // Show edit modal with the task data
      return LargeModal.show(
        context: context,
        title: 'Edit Task',
        subtitle: 'Update task details',
        content: [
          TaskEditWidget(
            task: taskToEdit,
            projectId: projectId,
            members: members,
            onTaskUpdated: onTaskUpdated,
          ),
        ],
        actions: [],  // Actions handled in the form widget
      );
    } catch (e) {
      // Close loading indicator if still showing
      if (Navigator.of(context).canPop()) {
        Navigator.of(context).pop();
      }
      
      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading task: $e')),
      );
    }
  }
  
  /// Shows a confirmation dialog before deleting a task
  static Future<bool> showDeleteTaskConfirmation({
    required BuildContext context,
    required String taskName,
  }) {
    return LargeModal.showConfirmation(
      context: context,
      title: 'Delete Task',
      message: 'Are you sure you want to delete "$taskName"? This action cannot be undone.',
      confirmLabel: 'Delete Task',
      confirmIcon: Icons.delete_forever,
      confirmColor: Colors.red,
      additionalContent: [
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.red.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.red.withOpacity(0.3)),
          ),
          child: Row(
            children: [
              Icon(Icons.warning_amber_rounded, color: Colors.red[300], size: 24),
              const SizedBox(width: 16),
              const Expanded(
                child: Text(
                  'Deleting a task is permanent and cannot be undone. All associated data will be lost.',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}