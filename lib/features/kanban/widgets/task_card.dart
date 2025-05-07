import 'package:flutter/material.dart';
import '../../../features/common/models/task_model.dart';

class KanbanTaskCard extends StatelessWidget {
  final Task task;
  final Function(Task task) onTap;
  final bool showActionIcons;
  final Function(Task task)? onEdit;
  final Function(Task task)? onDelete;

  const KanbanTaskCard({
    Key? key,
    required this.task,
    required this.onTap,
    this.showActionIcons = false,
    this.onEdit,
    this.onDelete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Get priority color - still useful for debugging even if not displayed
    Color priorityColor;
    try {
      switch (task.priority) {
        case 3:
          priorityColor = Colors.red;
          break;
        case 2:
          priorityColor = Colors.orange;
          break;
        default:
          priorityColor = Colors.green;
      }
    } catch (e) {
      print('Error determining priority color: $e');
      priorityColor = Colors.blue; // Default color
    }

    // Format deadline
    String deadline;
    try {
      deadline = "${task.endDate.day}/${task.endDate.month}/${task.endDate.year}";
    } catch (e) {
      print('Error formatting deadline: $e');
      deadline = "N/A";
    }
    
    // Build the task card
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
      elevation: 2.0,
      color: const Color(0xFF2C3034), // Darker card background
      child: Draggable<Task>(
        data: task,
        feedback: Material(
          elevation: 4.0,
          borderRadius: BorderRadius.circular(8.0),
          child: Container(
            width: 280, // Fixed width similar to original card
            padding: const EdgeInsets.all(12.0),
            decoration: BoxDecoration(
              color: const Color(0xFF2C3034),
              borderRadius: BorderRadius.circular(8.0),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min, // Keep it compact
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  task.taskName,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16.0,
                    color: Colors.white,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
                const SizedBox(height: 8.0),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    if (task.projectName != null && task.projectName!.isNotEmpty)
                      Flexible(
                        child: Text(
                          task.projectName!,
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 12.0,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      )
                    else
                      const SizedBox.shrink(),
                    Row(
                      children: [
                        const Icon(
                          Icons.calendar_today,
                          size: 12.0,
                          color: Colors.grey,
                        ),
                        const SizedBox(width: 4.0),
                        Text(
                          deadline,
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 12.0,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        childWhenDragging: Container(
          height: 80.0,
          margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
          decoration: BoxDecoration(
            color: const Color(0xFF3A444C), // Slightly lighter than background
            borderRadius: BorderRadius.circular(8.0),
            border: Border.all(color: Colors.grey.shade700),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 2.0,
                offset: const Offset(0, 1),
              ),
            ],
          ),
        ),
        child: InkWell(
          onTap: () => onTap(task),
          child: Container(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        task.taskName,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16.0,
                          color: Colors.white, // White text for contrast
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 2,
                      ),
                    ),
                    if (showActionIcons) ...[  // Only show action icons when specified
                      IconButton(
                        icon: const Icon(Icons.edit, size: 18.0, color: Colors.white70),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                        onPressed: onEdit != null ? () => onEdit!(task) : null,
                      ),
                      const SizedBox(width: 4.0),
                      IconButton(
                        icon: const Icon(Icons.delete, size: 18.0, color: Colors.red),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                        onPressed: onDelete != null ? () => onDelete!(task) : null,
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 8.0),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Display project name if available and we're not in project view
                    if (task.projectName != null)
                      Flexible(
                        child: Text(
                          task.projectName!,
                          style: const TextStyle(
                            color: Colors.grey, // Light gray for secondary text
                            fontSize: 12.0,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    Row(
                      children: [
                        const Icon(
                          Icons.calendar_today,
                          size: 12.0,
                          color: Colors.grey, // Light gray icon
                        ),
                        const SizedBox(width: 4.0),
                        Text(
                          deadline,
                          style: const TextStyle(
                            color: Colors.grey, // Light gray for secondary text
                            fontSize: 12.0,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                if (task.assignedMembers.isNotEmpty) ...[
                  const SizedBox(height: 8.0),
                  Row(
                    children: [
                      const Icon(
                        Icons.people,
                        size: 12.0,
                        color: Colors.grey, // Light gray icon
                      ),
                      const SizedBox(width: 4.0),
                      Expanded(
                        child: Text(
                          task.assignedMembers.map((m) => m.username).join(', '),
                          style: const TextStyle(
                            color: Colors.grey, // Light gray for secondary text
                            fontSize: 12.0,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}