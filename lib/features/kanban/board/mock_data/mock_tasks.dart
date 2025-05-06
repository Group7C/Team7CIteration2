// Mock data for kanban board testing
import 'package:flutter/material.dart';
import '../models/kanban_task.dart';

/// Mock tasks for testing the kanban board implementation
class MockTasks {
  /// Generate a list of mock tasks for demonstration
  static List<KanbanTask> getMockTasks() {
    return [
      // Project 1 Tasks
      KanbanTask(
        id: '1',
        title: 'Design UI mockups',
        description: 'Create mockups for all screens in the application',
        dueDate: DateTime.now().add(const Duration(days: 7)),
        status: 'todo',
        projectId: 'project1',
        projectName: 'Website Redesign',
        assigneeId: 'user1',
        assigneeName: 'John Doe',
        projectColour: Colors.blue,
      ),
      KanbanTask(
        id: '2',
        title: 'Implement login screen',
        description: 'Create login screen with validation',
        dueDate: DateTime.now().add(const Duration(days: 5)),
        status: 'in_progress',
        projectId: 'project1',
        projectName: 'Website Redesign',
        assigneeId: 'user2',
        assigneeName: 'Jane Smith',
        projectColour: Colors.blue,
      ),
      KanbanTask(
        id: '3',
        title: 'Write API documentation',
        description: 'Document all API endpoints for the frontend team',
        dueDate: DateTime.now().subtract(const Duration(days: 2)),
        status: 'completed',
        projectId: 'project1',
        projectName: 'Website Redesign',
        assigneeId: 'user3',
        assigneeName: 'Robert Johnson',
        projectColour: Colors.blue,
      ),
      
      // Project 2 Tasks
      KanbanTask(
        id: '4',
        title: 'Research competitors',
        description: 'Analyze top 5 competitors in the market',
        dueDate: DateTime.now().add(const Duration(days: 3)),
        status: 'todo',
        projectId: 'project2',
        projectName: 'Market Analysis',
        assigneeId: 'user1',
        assigneeName: 'John Doe',
        projectColour: Colors.green,
      ),
      KanbanTask(
        id: '5',
        title: 'Create survey',
        description: 'Design customer satisfaction survey',
        dueDate: DateTime.now().add(const Duration(days: 10)),
        status: 'todo',
        projectId: 'project2',
        projectName: 'Market Analysis',
        assigneeId: 'user4',
        assigneeName: 'Emily Wilson',
        projectColour: Colors.green,
      ),
      KanbanTask(
        id: '6',
        title: 'Analyze results',
        description: 'Compile and analyze survey results',
        dueDate: DateTime.now().subtract(const Duration(days: 1)),
        status: 'in_progress',
        projectId: 'project2',
        projectName: 'Market Analysis',
        assigneeId: 'user2',
        assigneeName: 'Jane Smith',
        projectColour: Colors.green,
      ),
      
      // Project 3 Tasks
      KanbanTask(
        id: '7',
        title: 'Create test plan',
        description: 'Design testing strategy for new features',
        dueDate: DateTime.now().add(const Duration(days: 4)),
        status: 'todo',
        projectId: 'project3',
        projectName: 'QA Testing',
        assigneeId: 'user5',
        assigneeName: 'Michael Brown',
        projectColour: Colors.purple,
      ),
      KanbanTask(
        id: '8',
        title: 'Run regression tests',
        description: 'Execute regression test suite on staging environment',
        dueDate: DateTime.now().add(const Duration(days: 2)),
        status: 'in_progress',
        projectId: 'project3',
        projectName: 'QA Testing',
        assigneeId: 'user3',
        assigneeName: 'Robert Johnson',
        projectColour: Colors.purple,
      ),
      KanbanTask(
        id: '9',
        title: 'Fix critical bugs',
        description: 'Address high priority bugs found during testing',
        dueDate: DateTime.now().subtract(const Duration(days: 3)),
        status: 'completed',
        projectId: 'project3',
        projectName: 'QA Testing',
        assigneeId: 'user1',
        assigneeName: 'John Doe',
        projectColour: Colors.purple,
      ),
    ];
  }
  
  /// Filter tasks by project ID
  static List<KanbanTask> getTasksByProject(String projectId) {
    return getMockTasks().where((task) => task.projectId == projectId).toList();
  }
  
  /// Filter tasks by assignee ID
  static List<KanbanTask> getTasksByAssignee(String assigneeId) {
    return getMockTasks().where((task) => task.assigneeId == assigneeId).toList();
  }
  
  /// Filter tasks by status
  static List<KanbanTask> getTasksByStatus(String status) {
    return getMockTasks().where((task) => task.status == status).toList();
  }
}