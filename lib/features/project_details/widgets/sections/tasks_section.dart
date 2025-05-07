import 'package:flutter/material.dart';
import '../empty_state_widget.dart';
import '../../../../features/common/widgets/section_card.dart';
import '../../../../features/common/widgets/action_button.dart';

class TasksSection extends StatelessWidget {
  final VoidCallback onAddTask;
  
  const TasksSection({
    Key? key,
    required this.onAddTask,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SectionCard(
      title: 'Tasks',
      height: 200,
      content: EmptyStateWidget(
        message: 'No tasks yet',
        icon: Icons.task_outlined,
        description: 'Create a task to get started',
      ),
      actionButton: ActionButton(
        label: 'Add Task',
        icon: Icons.add_task,
        onPressed: onAddTask,
        backgroundColor: Colors.blue,
        scale: 0.7,
      ),
    );
  }
}
