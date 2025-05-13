import 'package:flutter/material.dart';
import '../Objects/task.dart';
import '../providers/tasks_provider.dart';
import 'package:provider/provider.dart';

// kanban board component - drag and drop interface for task management
// supports filtering by project when projectUuid provided
class KanbanBoard extends StatefulWidget {
  final String? projectUuid; // optional project filter
  
  const KanbanBoard({super.key, this.projectUuid});

  @override
  State<KanbanBoard> createState() => _KanbanBoardState();
}

class _KanbanBoardState extends State<KanbanBoard> {
  bool _isUpdating = false; // prevents multiple simultaneous updates
  
  @override
  Widget build(BuildContext context) {
    // get tasks from provider
    final allTasks = Provider.of<TaskProvider>(context).tasks;
    
    // filter tasks if project specified, otherwise show all
    final tasks = widget.projectUuid != null 
        ? allTasks.where((task) => task.parentProject == widget.projectUuid).toList()
        : allTasks;
    
    // sort tasks into columns by status [ todo, in progress, completed ]
    final Map<String, List<Task>> columns = {
      'To Do': tasks.where((task) => task.status == Status.todo).toList(),
      'In Progress': tasks.where((task) => task.status == Status.inProgress).toList(),
      'Completed': tasks.where((task) => task.status == Status.completed).toList(),
    };

    // horizontally scrollable kanban board with fixed height
    return Container(
      height: 400, // fixed height so it fits nicely on home screen
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: columns.keys.map((columnTitle) {
            return _buildColumn(columnTitle, columns[columnTitle]!);
          }).toList(),
        ),
      ),
    );
  }

  // creates individual column for each status
  Widget _buildColumn(String title, List<Task> tasks) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return Container(
      width: 300,
      margin: const EdgeInsets.all(8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // column header with title and task count badge
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onPrimaryContainer,
                  ),
                ),
                // circular badge showing number of tasks in column
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: colorScheme.primary,
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    tasks.length.toString(),
                    style: TextStyle(
                      color: colorScheme.onPrimary,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          // drop zone for tasks [this is where dragged tasks land]
          Expanded(
            child: DragTarget<Task>(
              // prevent accepting new tasks while updating
              onWillAccept: (task) => !_isUpdating,
              // handle when task is dropped into this column
              onAccept: (task) async {
                // set appropriate status based on column title
                Status newStatus;
                switch (title) {
                  case 'In Progress':
                    newStatus = Status.inProgress;
                    break;
                  case 'Completed':
                    newStatus = Status.completed;
                    break;
                  default:
                    newStatus = Status.todo;
                }
                
                // skip update if status hasn't actually changed
                if (task.status == newStatus) return;
                
                // prevent further updates while we process this one
                setState(() {
                  _isUpdating = true;
                });
                
                // show feedback to user
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Updating task status...'),
                    duration: Duration(seconds: 1),
                  ),
                );
                
                // update task through provider [handles API calls]
                final taskProvider = Provider.of<TaskProvider>(context, listen: false);
                bool success = await taskProvider.updateTaskStatus(task, newStatus);
                
                // show result message
                if (mounted) {
                  ScaffoldMessenger.of(context).hideCurrentSnackBar();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(success 
                        ? 'Task status updated successfully' 
                        : 'Failed to update task status'),
                      backgroundColor: success ? Colors.green : Colors.red,
                      duration: const Duration(seconds: 2),
                    ),
                  );
                  
                  // allow further updates now this one's done
                  setState(() {
                    _isUpdating = false;
                  });
                }
              },
              // column styling changes when task is dragged over it
              builder: (context, candidateData, rejectedData) {
                return Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    // highlight when task hovers over
                    color: candidateData.isNotEmpty
                        ? colorScheme.primary.withOpacity(0.1)
                        : colorScheme.surfaceContainer,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: candidateData.isNotEmpty
                          ? colorScheme.primary
                          : colorScheme.outline,
                      width: candidateData.isNotEmpty ? 2 : 1,
                    ),
                  ),
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        // render all tasks in this column
                        ...tasks.map((task) {
                          return _buildTaskCard(task);
                        }).toList(),
                        // show placeholder when column is empty
                        if (tasks.isEmpty)
                          Container(
                            height: 100,
                            child: Center(
                              child: Text(
                                'Drop tasks here',
                                style: TextStyle(
                                  color: colorScheme.onSurfaceVariant.withOpacity(0.5),
                                  fontSize: 16,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // creates draggable task card - can refactor if you want
  Widget _buildTaskCard(Task task) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return Draggable<Task>(
      // task data that's transferred when dragged
      data: task,
      // improves drag handling from pointer position
      dragAnchorStrategy: pointerDragAnchorStrategy,
      // preview shown while dragging [floating card]
      feedback: Material(
        elevation: 4,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          width: 280,
          constraints: const BoxConstraints(maxWidth: 280),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: colorScheme.surface,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                task.title,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                task.description,
                style: TextStyle(
                  fontSize: 14,
                  color: colorScheme.onSurface,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
      // greyed out placeholder left behind during drag
      childWhenDragging: Opacity(
        opacity: 0.5,
        child: _buildTaskCardContent(task, true),
      ),
      // normal card appearance when not being dragged
      child: _buildTaskCardContent(task, false),
    );
  }

  // actual content of task cards [reused in multiple places]
  Widget _buildTaskCardContent(Task task, [bool isDragging = false]) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    // build layers of the card
    List<Widget> stackChildren = [
      Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // task title
            Text(
              task.title,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 4),
            // task description with truncation
            Text(
              task.description,
              style: TextStyle(
                fontSize: 14,
                color: colorScheme.onSurface,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 8),
            // metadata row [priority and due date]
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Priority: ${task.priority}',
                  style: TextStyle(
                    fontSize: 12,
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                Text(
                  task.endDate.toString().split(' ')[0],
                  style: TextStyle(
                    fontSize: 12,
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    ];
    
    // add loading spinner overlay when updating
    if (_isUpdating && !isDragging) {
      stackChildren.add(
        Positioned.fill(
          child: Container(
            color: Colors.black.withOpacity(0.1),
            child: const Center(
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          ),
        ),
      );
    }
    
    // put it all together
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: Card(
        elevation: isDragging ? 0 : 1,
        color: colorScheme.surface,
        child: Stack(
          children: stackChildren,
        ),
      ),
    );
  }
}