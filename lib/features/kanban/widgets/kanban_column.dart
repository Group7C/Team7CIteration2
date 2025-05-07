import 'package:flutter/material.dart';
import '../../../features/common/models/task_model.dart';
import 'task_card.dart';

class KanbanColumn extends StatelessWidget {
  final String title;
  final List<Task> tasks;
  final String status;
  final Function(Task task) onTaskTap;
  final Function(Task task, String newStatus) onTaskAccepted;
  final Color headerColor;
  final bool showActionIcons;
  final Function(Task task)? onEdit;
  final Function(Task task)? onDelete;

  const KanbanColumn({
    Key? key,
    required this.title,
    required this.tasks,
    required this.status,
    required this.onTaskTap,
    required this.onTaskAccepted,
    this.headerColor = Colors.blue,
    this.showActionIcons = false,
    this.onEdit,
    this.onDelete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 300,
      margin: const EdgeInsets.symmetric(horizontal: 8.0),
      decoration: BoxDecoration(
        color: const Color(0xFF212529), // Darker background to match project theme
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Column(
        children: [
          // Column header
          Container(
            padding: const EdgeInsets.all(12.0),
            decoration: BoxDecoration(
              color: headerColor,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(8.0),
                topRight: Radius.circular(8.0),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16.0,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 2.0),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                  child: Text(
                    tasks.length.toString(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          // Task list area - with DragTarget for drop detection
          Expanded(
            child: DragTarget<Task>(
              builder: (context, candidateTasks, rejectedTasks) {
                return Container(
                  color: candidateTasks.isNotEmpty
                      ? const Color(0xFF3A444C) // Darker highlight color when dragging over
                      : Colors.transparent,
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: tasks.isEmpty
                      ? _buildEmptyPlaceholder()
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(vertical: 4.0),
                          itemCount: tasks.length,
                          itemBuilder: (context, index) {
                            return KanbanTaskCard(
                            task: tasks[index],
                            onTap: onTaskTap,
                              showActionIcons: showActionIcons,
                          onEdit: onEdit,
                          onDelete: onDelete,
                        );
                          },
                        ),
                );
              },
              onAccept: (Task task) {
                // Only accept if the task isn't already in this status
                if (task.status != status) {
                  onTaskAccepted(task, status);
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  // Empty state placeholder
  Widget _buildEmptyPlaceholder() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.inbox,
            size: 48.0,
            color: Colors.grey, // Lighter gray icon for dark background
          ),
          const SizedBox(height: 16.0),
          const Text(
            'No tasks here',
            style: TextStyle(
              color: Colors.grey, // Light gray text for dark background
              fontSize: 16.0,
            ),
          ),
          const SizedBox(height: 8.0),
          const Text(
            'Drag tasks here',
            style: TextStyle(
              color: Colors.grey, // Light gray text for dark background
              fontSize: 14.0,
            ),
          ),
        ],
      ),
    );
  }
}
