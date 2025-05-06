import 'package:flutter/material.dart';
import 'info_section_container.dart';

class TasksListCard extends StatelessWidget {
  final VoidCallback? onAddTask;
  
  const TasksListCard({
    Key? key,
    this.onAddTask,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InfoSectionContainer(
      icon: Icons.task_alt,
      title: 'Tasks',
      iconColor: Colors.green,
      actionLabel: 'Add Task',
      actionIcon: Icons.add,
      onAction: onAddTask,
      children: [
        const SizedBox(height: 12),
        // This is a placeholder for real task list
        // In a real implementation, you would map through tasks
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: 3,
          itemBuilder: (context, index) {
            return _buildTaskItem(
              context,
              'Task ${index + 1}',
              index == 0 ? 'Completed' : index == 1 ? 'In Progress' : 'To Do',
              index == 0 ? Colors.green : index == 1 ? Colors.blue : Colors.grey,
            );
          },
        ),
        
        if (onAddTask != null)
          Padding(
            padding: const EdgeInsets.only(top: 12.0),
            child: Center(
              child: OutlinedButton.icon(
                onPressed: onAddTask,
                icon: const Icon(Icons.add, size: 16),
                label: const Text('View All Tasks'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
  
  Widget _buildTaskItem(BuildContext context, String title, String status, Color statusColor) {
    return Card(
      elevation: 0,
      color: Theme.of(context).colorScheme.surface,
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(6),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          children: [
            Container(
              width: 4,
              height: 36,
              decoration: BoxDecoration(
                color: statusColor,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Due in 3 days',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: statusColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                status,
                style: TextStyle(
                  color: statusColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
