import 'package:flutter_test/flutter_test.dart';
import 'package:sevenc_iteration_two/Objects/task.dart';

void main() {
  group('Task Model', () {
    // Basic task creation with valid parameters
    test('can be instantiated with valid parameters', () {
      final task = Task(
        title: 'Test Task',
        description: 'Test Description',
        percentageWeighting: 10.0,
        listOfTags: ['test'],
        priority: 2,
        startDate: DateTime(2024, 1, 1),
        endDate: DateTime(2024, 12, 31),
        members: {'Alice': 'Owner'},
        notificationPreference: true,
        notificationFrequency: NotificationFrequency.weekly,
        directoryPath: '/test/path',
        status: Status.todo
      );
      
      expect(task.title, 'Test Task');
      expect(task.description, 'Test Description');
      expect(task.percentageWeighting, 10.0);
      expect(task.listOfTags, ['test']);
      expect(task.priority, 2);
      expect(task.members, {'Alice': 'Owner'});
      expect(task.notificationPreference, true);
      expect(task.notificationFrequency, NotificationFrequency.weekly);
      expect(task.status, Status.todo);
    });
    
    // Test exception for invalid dates
    test('throws exception when end date is before start date', () {
      expect(() => Task(
        title: 'Invalid Date Task',
        description: 'Task with invalid dates',
        percentageWeighting: 10.0,
        listOfTags: ['test'],
        priority: 1,
        startDate: DateTime(2024, 2, 1),
        endDate: DateTime(2024, 1, 1), // Before start date
        members: {'Bob': 'Owner'},
        notificationPreference: true,
        notificationFrequency: NotificationFrequency.daily,
        directoryPath: '/test/path',
        status: Status.todo
      ), throwsArgumentError);
    });
    
    // Test exception for too long description
    test('throws exception when description is too long', () {
      expect(() => Task(
        title: 'Long Description Task',
        description: 'A' * 401, // 401 characters, exceeding the 400 limit
        percentageWeighting: 10.0,
        listOfTags: ['test'],
        priority: 1,
        startDate: DateTime(2024, 1, 1),
        endDate: DateTime(2024, 12, 31),
        members: {'Charlie': 'Owner'},
        notificationPreference: true,
        notificationFrequency: NotificationFrequency.daily,
        directoryPath: '/test/path',
        status: Status.todo
      ), throwsException);
    });
    
    // Test member management methods
    test('can add and remove members', () {
      final task = Task(
        title: 'Member Test Task',
        description: 'Testing member functions',
        percentageWeighting: 10.0,
        listOfTags: ['test'],
        priority: 1,
        startDate: DateTime(2024, 1, 1),
        endDate: DateTime(2024, 12, 31),
        members: {'Alice': 'Owner'},
        notificationPreference: true,
        notificationFrequency: NotificationFrequency.daily,
        directoryPath: '/test/path',
        status: Status.todo
      );
      
      // Test initial state
      expect(task.members.length, 1);
      expect(task.members['Alice'], 'Owner');
      
      // Test assignMember method
      task.assignMember('Bob', 'Editor');
      expect(task.members.length, 2);
      expect(task.members['Bob'], 'Editor');
      
      // Test getMembers method
      final membersList = task.getMembers();
      expect(membersList.length, 2);
      expect(membersList.contains('Alice'), true);
      expect(membersList.contains('Bob'), true);
      
      // Test removeMember method
      task.removeMember('Alice');
      expect(task.members.length, 1);
      expect(task.members.containsKey('Alice'), false);
      expect(task.members['Bob'], 'Editor');
    });
    
    // Test tag management methods
    test('can add, update and remove tags', () {
      final task = Task(
        title: 'Tag Test Task',
        description: 'Testing tag functions',
        percentageWeighting: 10.0,
        listOfTags: ['test'],
        priority: 1,
        startDate: DateTime(2024, 1, 1),
        endDate: DateTime(2024, 12, 31),
        members: {'Alice': 'Owner'},
        notificationPreference: true,
        notificationFrequency: NotificationFrequency.daily,
        directoryPath: '/test/path',
        status: Status.todo
      );
      
      // Test initial state
      expect(task.listOfTags.length, 1);
      expect(task.listOfTags[0], 'test');
      
      // Test addOrUpdateTag method - add new tag
      task.addOrUpdateTag('', 'new-tag');
      expect(task.listOfTags.length, 2);
      expect(task.listOfTags.contains('new-tag'), true);
      
      // Test addOrUpdateTag method - update existing tag
      task.addOrUpdateTag('test', 'updated-test');
      expect(task.listOfTags.length, 2);
      expect(task.listOfTags.contains('test'), false);
      expect(task.listOfTags.contains('updated-test'), true);
      
      // Test getTags method
      final tagsList = task.getTags();
      expect(tagsList?.length, 2);
      expect(tagsList?.contains('updated-test'), true);
      expect(tagsList?.contains('new-tag'), true);
      
      // Test removeTag method
      task.removeTag('new-tag');
      expect(task.listOfTags.length, 1);
      expect(task.listOfTags.contains('new-tag'), false);
      expect(task.listOfTags.contains('updated-test'), true);
    });
    
    // Test update methods
    test('can update task properties', () {
      final task = Task(
        title: 'Update Test Task',
        description: 'Original description',
        percentageWeighting: 10.0,
        listOfTags: ['test'],
        priority: 1,
        startDate: DateTime(2024, 1, 1),
        endDate: DateTime(2024, 12, 31),
        members: {'Alice': 'Owner'},
        notificationPreference: true,
        notificationFrequency: NotificationFrequency.daily,
        directoryPath: '/test/path',
        status: Status.todo
      );
      
      // Test updateTitle
      task.updateTitle('New Title');
      expect(task.title, 'New Title');
      
      // Test updateDescription
      task.updateDescription('Updated description');
      expect(task.description, 'Updated description');
      
      // Test updatePriority
      task.updatePriority(3);
      expect(task.priority, 3);
      
      // Test updatePercentageWeighting
      task.updatePercentageWeighting(20.0);
      expect(task.percentageWeighting, 20.0);
      
      // Test updateEndDate
      final newEndDate = DateTime(2025, 1, 1);
      task.updateEndDate(newEndDate);
      expect(task.endDate, newEndDate);
      
      // Test updateNotificationPreference
      task.updateNotificationPreference(false);
      expect(task.notificationPreference, false);
      
      // Test updateNotificationFrequency
      task.updateNotificationFrequency(NotificationFrequency.monthly);
      expect(task.notificationFrequency, NotificationFrequency.monthly);
      
      // Test updateStatus
      task.updateStatus(Status.inProgress);
      expect(task.status, Status.inProgress);
    });
    
    // Test validation in update methods
    test('validates updates to properties', () {
      final task = Task(
        title: 'Validation Test Task',
        description: 'Original description',
        percentageWeighting: 10.0,
        listOfTags: ['test'],
        priority: 1,
        startDate: DateTime(2024, 1, 1),
        endDate: DateTime(2024, 12, 31),
        members: {'Alice': 'Owner'},
        notificationPreference: true,
        notificationFrequency: NotificationFrequency.daily,
        directoryPath: '/test/path',
        status: Status.todo
      );
      
      // Test updateEndDate validation
      expect(() => 
        task.updateEndDate(DateTime(2023, 1, 1)), // Before start date
        throwsException
      );
      
      // Test updateDescription validation
      expect(() => 
        task.updateDescription('A' * 401), // 401 characters
        throwsException
      );
    });
  });
}