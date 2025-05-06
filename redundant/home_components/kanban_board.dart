// lib/features/home/widgets/kanban_board.dart
import 'package:flutter/material.dart';

class KanbanBoard extends StatelessWidget {
  const KanbanBoard({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: _buildKanbanColumn(
            context,
            "To Do",
            [
              _TaskItem(
                title: "Research API options",
                project: "Backend Development",
                dueDate: "Apr 15",
                priority: "High",
                assignee: "Me",
              ),
              _TaskItem(
                title: "Design database schema",
                project: "Backend Development",
                dueDate: "Apr 20",
                priority: "Medium",
                assignee: "Me",
              ),
            ],
            Colors.grey,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildKanbanColumn(
            context,
            "In Progress",
            [
              _TaskItem(
                title: "Create login page",
                project: "Frontend Development",
                dueDate: "Apr 12",
                priority: "High",
                assignee: "Me",
              ),
            ],
            Colors.blue,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildKanbanColumn(
            context,
            "Review",
            [
              _TaskItem(
                title: "Update README file",
                project: "Documentation",
                dueDate: "Apr 10",
                priority: "Low",
                assignee: "Me",
              ),
            ],
            Colors.amber,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildKanbanColumn(
            context,
            "Done",
            [
              _TaskItem(
                title: "Setup project repository",
                project: "DevOps",
                dueDate: "Apr 5",
                priority: "Medium",
                assignee: "Me",
              ),
              _TaskItem(
                title: "Define project requirements",
                project: "Planning",
                dueDate: "Apr 3",
                priority: "High",
                assignee: "Me",
              ),
            ],
            Colors.green,
          ),
        ),
      ],
    );
  }

  Widget _buildKanbanColumn(
    BuildContext context,
    String title,
    List<_TaskItem> tasks,
    Color color,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Column header
        Container(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
          decoration: BoxDecoration(
            color: color.withOpacity(0.2),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
              Text(
                "${tasks.length}",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        // Task cards
        Expanded(
          child: ListView.builder(
            itemCount: tasks.length,
            itemBuilder: (context, index) {
              return _buildTaskCard(context, tasks[index]);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildTaskCard(BuildContext context, _TaskItem task) {
    // Map priority to color
    Color priorityColor;
    switch (task.priority.toLowerCase()) {
      case "high":
        priorityColor = Colors.red;
        break;
      case "medium":
        priorityColor = Colors.orange;
        break;
      default:
        priorityColor = Colors.green;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title
            Text(
              task.title,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 4),
            // Project
            Text(
              task.project,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            // Bottom row with metadata
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Due date
                Row(
                  children: [
                    Icon(
                      Icons.calendar_today,
                      size: 12,
                      color: Colors.grey[600],
                    ),
                    const SizedBox(width: 4),
                    Text(
                      task.dueDate,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
                // Priority badge
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: priorityColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    task.priority,
                    style: TextStyle(
                      fontSize: 10,
                      color: priorityColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                // Assignee
                Row(
                  children: [
                    Icon(
                      Icons.person,
                      size: 12,
                      color: Colors.grey[600],
                    ),
                    const SizedBox(width: 4),
                    Text(
                      task.assignee,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// Task data model
class _TaskItem {
  final String title;
  final String project;
  final String dueDate;
  final String priority;
  final String assignee;

  _TaskItem({
    required this.title,
    required this.project,
    required this.dueDate,
    required this.priority,
    required this.assignee,
  });
}
