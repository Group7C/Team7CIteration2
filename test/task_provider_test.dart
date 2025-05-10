import 'package:flutter_test/flutter_test.dart';
import 'package:sevenc_iteration_two/providers/tasks_provider.dart';
import 'package:sevenc_iteration_two/Objects/task.dart';

void main() {
  group('TaskProvider', () {
    test('can add and retrieve a Task', () {
      final provider = TaskProvider();

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
      );

      provider.addTask(task);

      expect(provider.tasks.length, 1);
      expect(provider.getTask('Test Task')?.description, 'Testing task provider');
    });
  });
}
