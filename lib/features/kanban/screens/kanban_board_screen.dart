import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../features/common/models/task_model.dart';
import '../controllers/kanban_controller.dart';
import '../widgets/kanban_column.dart';

class KanbanBoardScreen extends StatefulWidget {
  final int? projectId; // Optional: for filtering by project
  final int? userId; // Optional: for filtering by user
  final Function(Task)? onTaskTap; // Optional: callback when a task is tapped
  final bool showActionIcons; // Whether to show edit/delete icons
  final Function(Task)? onEdit; // Optional: callback when edit icon is tapped
  final Function(Task)? onDelete; // Optional: callback when delete icon is tapped
  final Function(Task, String)? onStatusChanged; // Optional: callback when task status changes
  final Task? newTask; // NEW: Optional task that was just created

  const KanbanBoardScreen({
    Key? key,
    this.projectId,
    this.userId,
    this.onTaskTap,
    this.showActionIcons = false,
    this.onEdit,
    this.onDelete,
    this.onStatusChanged,
    this.newTask, // NEW: Add this parameter
  }) : super(key: key);

  @override
  State<KanbanBoardScreen> createState() => _KanbanBoardScreenState();
}

class _KanbanBoardScreenState extends State<KanbanBoardScreen> {
  late final KanbanController _controller;

  @override
  void initState() {
    super.initState();
    _controller = KanbanController();
    _loadTasks();
  }
  
  @override
  void didUpdateWidget(KanbanBoardScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    // If a new task was passed and it's different from the previous one
    if (widget.newTask != null && widget.newTask != oldWidget.newTask) {
      print('KanbanBoardScreen: New task detected - adding to board');
      _controller.addNewTask(widget.newTask!);
    }
  }

  Future<void> _loadTasks() async {
    try {
      if (widget.projectId != null) {
        print('KanbanBoardScreen: Loading tasks for project ID: ${widget.projectId}');
      } else if (widget.userId != null) {
        print('KanbanBoardScreen: Loading tasks for user ID: ${widget.userId}');
      } else {
        print('KanbanBoardScreen: No project or user ID provided');
      }
      
      await _controller.initTasks(
        projectId: widget.projectId,
        userId: widget.userId,
      );
    } catch (e) {
      print('KanbanBoardScreen: Error loading tasks: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _controller,
      child: Consumer<KanbanController>(
        builder: (context, controller, _) {
          if (controller.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          return RefreshIndicator(
            onRefresh: controller.refreshTasks,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Removed the "Task Board" title as requested
                  Expanded(
                    child: Center(
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Container(
                          height: MediaQuery.of(context).size.height,
                          padding: const EdgeInsets.all(8.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              // To Do Column
                              KanbanColumn(
                                title: 'To Do',
                                tasks: controller.todoTasks,
                                status: 'to_do',
                                headerColor: Colors.blue,
                                onTaskTap: widget.onTaskTap ?? (task) {},
                                showActionIcons: widget.showActionIcons,
                                onEdit: widget.onEdit,
                                onDelete: widget.onDelete,
                                onTaskAccepted: (task, newStatus) {
                                  controller.moveTask(task, newStatus).then((success) {
                                    if (success && widget.onStatusChanged != null) {
                                      widget.onStatusChanged!(task, newStatus);
                                    }
                                  });
                                },
                              ),
                              
                              // In Progress Column
                              KanbanColumn(
                                title: 'In Progress',
                                tasks: controller.inProgressTasks,
                                status: 'in_progress',
                                headerColor: Colors.orange,
                                onTaskTap: widget.onTaskTap ?? (task) {},
                                showActionIcons: widget.showActionIcons,
                                onEdit: widget.onEdit,
                                onDelete: widget.onDelete,
                                onTaskAccepted: (task, newStatus) {
                                  controller.moveTask(task, newStatus).then((success) {
                                    if (success && widget.onStatusChanged != null) {
                                      widget.onStatusChanged!(task, newStatus);
                                    }
                                  });
                                },
                              ),
                              
                              // Complete Column
                              KanbanColumn(
                                title: 'Complete',
                                tasks: controller.completeTasks,
                                status: 'complete',
                                headerColor: Colors.green,
                                onTaskTap: widget.onTaskTap ?? (task) {},
                                showActionIcons: widget.showActionIcons,
                                onEdit: widget.onEdit,
                                onDelete: widget.onDelete,
                                onTaskAccepted: (task, newStatus) {
                                  controller.moveTask(task, newStatus).then((success) {
                                    if (success && widget.onStatusChanged != null) {
                                      widget.onStatusChanged!(task, newStatus);
                                    }
                                  });
                                },
                              ),
                            ],
                          ),
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
    );
  }
}