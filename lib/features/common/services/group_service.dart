import '../models/group_model.dart';
import '../models/task_model.dart';
import 'task_service.dart';

class GroupService {
  // Get all groups (tasks with multiple assignees) for a user
  static Future<List<Group>> getUserGroups(int userId) async {
    try {
      // Fetch all tasks assigned to the user
      final tasks = await TaskService.getTasksByUser(userId);
      
      // Filter for tasks that have multiple assignees (groups)
      final List<Group> groups = [];
      
      for (final task in tasks) {
        // Include tasks that have more than one person assigned (current user + others)
        if (task.assignedMembers.length > 1) {
          // Create a Group from the Task
          final group = Group.fromTask(task);
          
          // Only include if this user is actually a member
          if (group.isMember(userId)) {
            groups.add(group);
          }
        }
      }
      
      // Sort by deadline (closest first)
      groups.sort((a, b) => a.deadline.compareTo(b.deadline));
      
      return groups;
    } catch (e) {
      print('Error fetching user groups: $e');
      throw Exception('Failed to load groups: $e');
    }
  }
  
  // Get task details for a specific group
  static Future<Task?> getGroupTask(int taskId) async {
    try {
      // For now, we can't directly fetch a single task by ID, 
      // so this is a placeholder. In a real implementation, 
      // you'd create an API endpoint to get a task by ID.
      return null;
    } catch (e) {
      print('Error fetching group task: $e');
      return null;
    }
  }
}
