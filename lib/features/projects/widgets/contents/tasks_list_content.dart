import 'package:flutter/material.dart';
import '../../../../features/kanban/board/containers/project_kanban.dart';
import '../../../projects/models/project.dart';

class TasksListContent extends StatelessWidget {
  final String? projectId;
  final Project? project;
  
  const TasksListContent({Key? key, this.projectId, this.project}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Determine which project ID to use
    final String effectiveProjectId = projectId ?? 
                                      (project != null ? project!.name.replaceAll(' ', '').toLowerCase() : 'project1');
                                      
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 12),
        // Use our Kanban implementation with a fixed height
        SizedBox(
          height: 500, // Fixed height to match the inspiration project
          child: ProjectKanban(
            projectId: effectiveProjectId,
            projectColor: project?.colour ?? Theme.of(context).colorScheme.primary,
          ),
        ),
      ],
    );
  }
}
