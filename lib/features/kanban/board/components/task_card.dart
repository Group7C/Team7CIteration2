// Task card - visual representation of individual tasks [draggable between columns]
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/kanban_task.dart';

class KanbanTaskCard extends StatelessWidget {
  final KanbanTask task;
  final bool showActions; // Flag to show or hide edit/delete actions
  final Future<void> Function(KanbanTask)? onEdit;
  final Function(KanbanTask)? onDelete;
  final Function(KanbanTask)? onTap; // For navigating to project details
  
  // Takes task object and renders all its details
  const KanbanTaskCard({
    Key? key,
    required this.task,
    this.showActions = false, // Default to false (home page cards won't show actions)
    this.onEdit,
    this.onDelete,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(
          color: task.projectColour.withOpacity(0.5),
          width: 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap != null ? () => onTap!(task) : null,
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Task title with actions row
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Task title - most prominent element [limited to 2 lines]
                    Expanded(
                      child: Text(
                        task.title,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    
                    // Action buttons (only shown for project screen cards)
                    if (showActions) ...[                  
                      IconButton(
                        icon: Icon(Icons.edit, size: 18),
                        padding: EdgeInsets.zero,
                        constraints: BoxConstraints(),
                        onPressed: onEdit != null ? () async {
                          await onEdit!(task);
                        } : null,
                        tooltip: 'Edit',
                        color: theme.colorScheme.primary,
                      ),
                      const SizedBox(width: 4),
                      IconButton(
                        icon: Icon(Icons.delete, size: 18),
                        padding: EdgeInsets.zero,
                        constraints: BoxConstraints(),
                        onPressed: onDelete != null ? () => onDelete!(task) : null,
                        tooltip: 'Delete',
                        color: Colors.red,
                      ),
                    ],
                  ],
                ),
              
                const SizedBox(height: 8),
                
                // Project badge - coloured chip showing which project task belongs to
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: task.projectColour.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    task.projectName,
                    style: TextStyle(
                      fontSize: 12,
                      color: task.projectColour,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                
                const SizedBox(height: 8),
                
                // Due date - shows deadline with red highlight if overdue
                Row(
                  children: [
                    Icon(
                      Icons.calendar_today,
                      size: 14,
                      color: task.isOverdue ? Colors.red : theme.colorScheme.onSurface.withOpacity(0.6),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      DateFormat('MMM d, yyyy').format(task.dueDate),
                      style: TextStyle(
                        fontSize: 12,
                        color: task.isOverdue ? Colors.red : theme.colorScheme.onSurface.withOpacity(0.6),
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 4),
                
                // Assignee - shows who's responsible for task
                Row(
                  children: [
                    Icon(
                      Icons.person_outline,
                      size: 14,
                      color: theme.colorScheme.onSurface.withOpacity(0.6),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      task.assigneeName,
                      style: TextStyle(
                        fontSize: 12,
                        color: theme.colorScheme.onSurface.withOpacity(0.6),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}