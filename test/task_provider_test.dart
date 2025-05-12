import 'package:flutter_test/flutter_test.dart';
import 'package:sevenc_iteration_two/providers/tasks_provider.dart';
import 'package:sevenc_iteration_two/Objects/task.dart';

void main() {
  group('Task Class Tests', () {
    late Task task;
    final defaultStart = DateTime(2025, 5, 10);
    final defaultEnd = DateTime(2025, 5, 20);

    setUp(() {
      task = Task(
        title: 'Test Task',
        status: Status.todo,
        percentageWeighting: 0.5,
        listOfTags: ['Urgent'],
        priority: 3,
        startDate: defaultStart,
        endDate: defaultEnd,
        description: 'A description',
        members: {'alice': 'Editor'},
        notificationPreference: true,
        notificationFrequency: NotificationFrequency.daily,
        directoryPath: '/tasks',
      );
    });

    test('Constructor throws when endDate is before startDate', () {
      expect(
          () => Task(
                title: 'Test',
                status: Status.todo,
                percentageWeighting: 0.5,
                listOfTags: [],
                priority: 2,
                startDate: DateTime(2025, 5, 10),
                endDate: DateTime(2025, 5, 5),
                description: 'desc',
                members: {},
                notificationPreference: true,
                notificationFrequency: NotificationFrequency.daily,
                directoryPath: '/tasks',
              ),
          throwsA(isA<ArgumentError>()));
    });

    test('Assign member successfully', () {
      task.assignMember('bob', Role.editor, ['bob', 'alice']);
      expect(task.members['bob'], 'Editor');
    });

    test('Assign member throws for invalid username', () {
      expect(() => task.assignMember('charlie', Role.reader, ['bob', 'alice']),
          throwsA(isA<ArgumentError>()));
    });

    test('Remove member successfully', () {
      task.removeMember('alice');
      expect(task.members.containsKey('alice'), false);
    });

    test('Remove member throws for empty username', () {
      expect(() => task.removeMember(''), throwsA(isA<ArgumentError>()));
    });

    test('Add new tag successfully', () {
      task.addOrUpdateTag(null, 'Important');
      expect(task.listOfTags, contains('Important'));
    });

    test('Modify existing tag successfully', () {
      task.addOrUpdateTag('Urgent', ' Very Urgent');
      expect(task.listOfTags.contains('Very Urgent'), true);
      expect(task.listOfTags.contains('Urgent'), false);
    });

    test('Remove tag successfully', () {
      task.removeTag('Urgent');
      expect(task.listOfTags.contains('Urgent'), false);
    });

    test('Update priority throws for invalid value', () {
      expect(() => task.updatePriority(6), throwsA(isA<ArgumentError>()));
      expect(() => task.updatePriority(-1), throwsA(isA<ArgumentError>()));
      });

    test('Update priority successfully', () {
      task.updatePriority(1);
      expect(task.priority, 1);
      task.updatePriority(2);
      expect(task.priority, 2);
      task.updatePriority(3);
      expect(task.priority, 3);
      task.updatePriority(4);
      expect(task.priority, 4);
      task.updatePriority(5);
      expect(task.priority, 5);
    });
    test('Update start date successfully', () {
      task.updateStartDate(DateTime(2025, 5, 15));
      expect(task.startDate, DateTime(2025, 5, 15));
    });

    test('Update end date throws if before start date', () {
      expect(() => task.updateEndDate(DateTime(2025, 5, 1)),
          throwsA(isA<Exception>()));
    });
    
    test('Update description throws if null', () {
      expect(() => task.updateDescription(null),
          throwsA(isA<ArgumentError>()));
    });
    test('Update description successfully', () {
      task.updateDescription('This is my new description');
      expect(task.description, 'This is my new description');
    });

    test('Update title throws if null', () {
      expect(() => task.updateTitle(null), throwsA(isA<ArgumentError>()));
    });
    test('Update title throws if empty', () {
      expect(() => task.updateTitle(''), throwsA(isA<ArgumentError>()));
    });
    test('Update title successfully', () {
      task.updateTitle('Add Test File');
      expect(task.title, 'Add Test File');
    });

    test('Update notification preference to false changes frequency to none', () {
      task.updateNotificationPreference(false);
      expect(task.notificationPreference, false);
      expect(task.notificationFrequency, NotificationFrequency.none);
    });
    test('Update notification preference to true successfully', () {
      task.updateNotificationPreference(true);
      expect(task.notificationPreference, true);    
    });

    test('Can edit returns true for member', () {
      expect(task.canEdit('alice'), true);
    });

    test('Can edit returns false for non-member', () {
      expect(task.canEdit('bob'), false);
    });

    test('Update status successfully', () {
      task.updateStatus(Status.inProgress);
      expect(task.status, Status.inProgress);
    });
  });
}