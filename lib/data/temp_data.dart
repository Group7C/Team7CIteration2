// lib/data/temp_data.dart
// temp storage for my data for my kanban board, will link it to a db later - Luke
import '../models/task.dart';

class KanbanData {
  static List<Task> tasks = [
    Task(
      id: '1',
      title: 'Implement login screen',
      dueDate: '2024-02-20',
      assignee: 'John Doe',
      status: 'todo',
    ),
    Task(
      id: '2',
      title: 'Design system architecture',
      dueDate: '2024-02-21',
      assignee: 'Jane Smith',
      status: 'todo',
    ),
    Task(
      id: '3',
      title: 'Create API documentation',
      dueDate: '2024-02-19',
      assignee: 'John Doe',
      status: 'in_progress',
    ),
    Task(
      id: '4',
      title: 'Set up CI/CD pipeline',
      dueDate: '2024-02-22',
      assignee: 'Jane Smith',
      status: 'in_progress',
    ),
    Task(
      id: '5',
      title: 'Write unit tests',
      dueDate: '2024-02-18',
      assignee: 'John Doe',
      status: 'completed',
    ),
  ];

  static void updateTaskStatus(String taskId, String newStatus) {
    final taskIndex = tasks.indexWhere((task) => task.id == taskId);
    if (taskIndex != -1) {
      tasks[taskIndex] = tasks[taskIndex].copyWith(status: newStatus);
    }
  }

  static List<Task> getTasksByStatus(String status) {
    return tasks.where((task) => task.status == status).toList();
  }
}
