import 'package:flutter/material.dart';
import '../widgets/project_form_widget.dart';
import '../../../features/common/modals/large_modal.dart';
import '../../../features/common/models/project_model.dart';

class ProjectModalService {
  /// Shows the project editing modal using the LargeModal component
  static Future<void> showEditProjectModal({
    required BuildContext context,
    required Project project,
    VoidCallback? onProjectUpdated,
  }) {
    return LargeModal.show(
      context: context,
      title: 'Edit Project',
      subtitle: 'Update project details',
      content: [
        ProjectFormWidget(
          project: project,
          onSubmitSuccess: onProjectUpdated,
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
  
  /// Shows a confirmation dialog before deleting a project
  static Future<bool> showDeleteProjectConfirmation({
    required BuildContext context,
    required String projectName,
  }) {
    return LargeModal.showConfirmation(
      context: context,
      title: 'Delete Project',
      message: 'Are you sure you want to delete "$projectName"? This action cannot be undone and will remove all tasks, meetings, and other data associated with this project.',
      confirmLabel: 'Delete Project',
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
                  'Deleting a project is permanent and cannot be undone. All associated data will be lost.',
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
