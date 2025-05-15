import 'package:flutter_test/flutter_test.dart';
import 'package:sevenc_iteration_two/providers/tasks_provider.dart';
import 'package:sevenc_iteration_two/Objects/task.dart';

void main() {
  group('TaskProvider', () {
    late TaskProvider provider;
    
    setUp(() {
      provider = TaskProvider();
    });
    
    test('can add and retrieve a Task', () {
      print("=== Adding Task Locally ===");
      final task = Task(
        title: 'Test Task',
        description: 'Testing task provider',
        percentageWeighting: 1.0,
        listOfTags: ['test'],
        priority: 1,
        startDate: DateTime(2024, 1, 1),
        endDate: DateTime(2024, 12, 31),
        members: {'Tudor': 'Owner'},
        notificationPreference: true,
        notificationFrequency: NotificationFrequency.daily,
        directoryPath: '/test/path',
        status: Status.todo
      );

      print("Task: ${task.title}");
      print("Members: ${task.members}");

      provider.addTask(task);

      expect(provider.tasks.length, 1);
      expect(provider.getTask('Test Task')?.description, 'Testing task provider');
    });
    
    test('can update a Task', () {
      // Add initial task
      final task = Task(
        title: 'Update Test Task',
        description: 'Original description',
        percentageWeighting: 1.0,
        listOfTags: ['test'],
        priority: 1,
        startDate: DateTime(2024, 1, 1),
        endDate: DateTime(2024, 12, 31),
        members: {'Tudor': 'Owner'},
        notificationPreference: true,
        notificationFrequency: NotificationFrequency.daily,
        directoryPath: '/test/path',
        status: Status.todo
      );

      provider.addTask(task);
      expect(provider.tasks.length, 1);
      
      // Verify initial state
      Task? initialTask = provider.getTask('Update Test Task');
      expect(initialTask?.description, 'Original description');
      expect(initialTask?.priority, 1);
      expect(initialTask?.status, Status.todo);
      
      // Update task properties
      initialTask?.updateDescription('Updated description');
      initialTask?.updatePriority(3);
      initialTask?.updateStatus(Status.inProgress);
      initialTask?.addOrUpdateTag('', 'new-tag');
      
      // Verify updated state
      Task? updatedTask = provider.getTask('Update Test Task');
      expect(updatedTask?.description, 'Updated description');
      expect(updatedTask?.priority, 3);
      expect(updatedTask?.status, Status.inProgress);
      expect(updatedTask?.listOfTags.contains('new-tag'), true);
    });
    
    test('can delete a Task', () {
      // Add a task
      final task = Task(
        title: 'Delete Test Task',
        description: 'This task will be deleted',
        percentageWeighting: 1.0,
        listOfTags: ['test'],
        priority: 1,
        startDate: DateTime(2024, 1, 1),
        endDate: DateTime(2024, 12, 31),
        members: {'Tudor': 'Owner'},
        notificationPreference: true,
        notificationFrequency: NotificationFrequency.daily,
        directoryPath: '/test/path',
        status: Status.todo
      );

      provider.addTask(task);
      expect(provider.tasks.length, 1);
      
      // Delete the task
      Task? taskToDelete = provider.getTask('Delete Test Task');
      expect(taskToDelete, isNotNull);
      provider.removeTask(taskToDelete!);
      expect(provider.tasks.length, 0);
      expect(provider.getTask('Delete Test Task'), isNull);
    });
    
    test('can search tasks by title', () {
      // Add multiple tasks
      provider.addTask(Task(
        title: 'UI Design Task',
        description: 'Design the user interface',
        percentageWeighting: 1.0,
        listOfTags: ['design', 'ui'],
        priority: 2,
        startDate: DateTime(2024, 1, 1),
        endDate: DateTime(2024, 1, 15),
        members: {'Designer': 'Owner'},
        notificationPreference: true,
        notificationFrequency: NotificationFrequency.daily,
        directoryPath: '/design/path',
        status: Status.todo
      ));
      
      provider.addTask(Task(
        title: 'Backend API Task',
        description: 'Implement the backend API',
        percentageWeighting: 2.0,
        listOfTags: ['backend', 'api'],
        priority: 1,
        startDate: DateTime(2024, 1, 5),
        endDate: DateTime(2024, 1, 25),
        members: {'Developer': 'Owner'},
        notificationPreference: true,
        notificationFrequency: NotificationFrequency.weekly,
        directoryPath: '/backend/path',
        status: Status.todo
      ));
      
      provider.addTask(Task(
        title: 'Testing Task',
        description: 'Test the application',
        percentageWeighting: 1.5,
        listOfTags: ['testing', 'qa'],
        priority: 3,
        startDate: DateTime(2024, 1, 20),
        endDate: DateTime(2024, 2, 5),
        members: {'Tester': 'Owner'},
        notificationPreference: false,
        notificationFrequency: NotificationFrequency.none,
        directoryPath: '/testing/path',
        status: Status.todo
      ));
      
      // Search for tasks
      final designTask = provider.getTask('UI Design Task');
      final apiTask = provider.getTask('Backend API Task');
      final testingTask = provider.getTask('Testing Task');
      
      expect(designTask?.description, 'Design the user interface');
      expect(apiTask?.description, 'Implement the backend API');
      expect(testingTask?.description, 'Test the application');
      
      // Check that a non-existent task returns null
      expect(provider.getTask('Non-existent Task'), isNull);
    });
    
    test('can update task status', () {
      // Add a task
      final task = Task(
        title: 'Status Test Task',
        description: 'Testing status updates',
        percentageWeighting: 1.0,
        listOfTags: ['test'],
        priority: 1,
        startDate: DateTime(2024, 1, 1),
        endDate: DateTime(2024, 12, 31),
        members: {'Tester': 'Owner'},
        notificationPreference: true,
        notificationFrequency: NotificationFrequency.daily,
        directoryPath: '/test/path',
        status: Status.todo
      );

      provider.addTask(task);
      
      // Initial status
      Task? initialTask = provider.getTask('Status Test Task');
      expect(initialTask?.status, Status.todo);
      
      // Update to in progress
      initialTask?.updateStatus(Status.inProgress);
      expect(provider.getTask('Status Test Task')?.status, Status.inProgress);
      
      // Update to completed
      initialTask?.updateStatus(Status.completed);
      expect(provider.getTask('Status Test Task')?.status, Status.completed);
    });
  });
}