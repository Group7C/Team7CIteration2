import 'package:flutter/material.dart';
import '../widgets/create_project_form_widget.dart';
import '../../../features/common/modals/large_modal.dart';

class ProjectsModalService {
  /// Shows the project creation modal using the LargeModal component
  static Future<void> showCreateProjectModal({
    required BuildContext context,
    VoidCallback? onProjectCreated,
  }) {
    return LargeModal.show(
      context: context,
      title: 'Create New Project',
      subtitle: 'Create a new project to organize your tasks and collaborate with team members',
      content: [
        CreateProjectFormWidget(
          onSubmitSuccess: onProjectCreated,
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
}
