// lib/home/components/kanban_board/kanban_column.dart
import 'package:flutter/material.dart';
import '../../../models/task.dart';
import 'task_card.dart';

class KanbanColumn extends StatelessWidget {
  final String title;
  final String status;
  final List<Task> tasks;
  final Function(String taskId, String newStatus) onTaskMoved;

  const KanbanColumn({
    super.key,
    required this.title,
    required this.status,
    required this.tasks,
    required this.onTaskMoved,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return DragTarget<Task>(
      onWillAccept: (task) => true,
      onAccept: (task) {
        onTaskMoved(task.id, status);
      },
      builder: (context, candidateData, rejectedData) {
        return Container(
          decoration: BoxDecoration(
            color: candidateData.isNotEmpty
                ? colorScheme.primaryContainer.withOpacity(0.3)
                : colorScheme.surfaceBright,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: colorScheme.outline,
              width: 1,
            ),
          ),
          child: Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: colorScheme.onSurface,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 12),
                Expanded(
                  child: ListView.builder(
                    itemCount: tasks.length,
                    itemBuilder: (context, index) {
                      final task = tasks[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8.0),
                        child: Draggable<Task>(
                          data: task,
                          feedback: Material(
                            elevation: 4.0,
                            child: SizedBox(
                              width: MediaQuery.of(context).size.width * 0.2,
                              child: TaskCard(
                                title: task.title,
                                dueDate: task.dueDate,
                                assignee: task.assignee,
                              ),
                            ),
                          ),
                          childWhenDragging: Opacity(
                            opacity: 0.5,
                            child: TaskCard(
                              title: task.title,
                              dueDate: task.dueDate,
                              assignee: task.assignee,
                            ),
                          ),
                          child: TaskCard(
                            title: task.title,
                            dueDate: task.dueDate,
                            assignee: task.assignee,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
