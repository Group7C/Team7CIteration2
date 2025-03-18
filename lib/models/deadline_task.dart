// lib/models/deadline_task.dart
class DeadlineTask {
  final String id;
  final String title;
  final String project;
  final String time;
  final String priority; // 'high', 'medium', 'low'
  final DateTime date;

  DeadlineTask({
    required this.id,
    required this.title,
    required this.project, 
    required this.time,
    required this.priority,
    required this.date,
  });
}

// Sample data class for testing
class DeadlineSampleData {
  static List<DeadlineTask> generateTasks() {
    final tasks = <DeadlineTask>[];
    final now = DateTime.now();
    
    // Create tasks on specific days over next 3 months
    final deadlineDays = [0, 2, 5, 9, 14, 21, 30, 45, 60];
    
    for (var i = 0; i < deadlineDays.length; i++) {
      final dayOffset = deadlineDays[i];
      final date = DateTime(
        now.year, 
        now.month, 
        now.day + dayOffset,
      );
      
      // Add 1-2 tasks per deadline day
      final taskCount = i % 2 == 0 ? 2 : 1;
      
      for (var j = 0; j < taskCount; j++) {
        String priority;
        if (i % 5 == 0) {
          priority = 'high';
        } else if (i % 3 == 0) {
          priority = 'medium';
        } else {
          priority = 'low';
        }
        
        tasks.add(
          DeadlineTask(
            id: 'task-${tasks.length + 1}',
            title: 'Task ${tasks.length + 1}',
            project: 'Team 7C',
            time: '${(j + 9) % 12 + 1}:00 ${j % 2 == 0 ? 'AM' : 'PM'}',
            priority: priority,
            date: date,
          ),
        );
      }
    }
    
    return tasks;
  }
  
  // Group tasks by date
  static Map<String, List<DeadlineTask>> groupTasksByDate(List<DeadlineTask> tasks) {
    final Map<String, List<DeadlineTask>> grouped = {};
    
    for (final task in tasks) {
      final dateString = '${task.date.year}-${task.date.month}-${task.date.day}';
      if (!grouped.containsKey(dateString)) {
        grouped[dateString] = [];
      }
      grouped[dateString]!.add(task);
    }
    
    return grouped;
  }
}
