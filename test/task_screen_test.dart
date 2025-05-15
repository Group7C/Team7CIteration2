import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:sevenc_iteration_two/tasks/add_task_screen.dart';
import 'package:sevenc_iteration_two/providers/tasks_provider.dart';
import 'package:sevenc_iteration_two/providers/projects_provider.dart';
import 'package:sevenc_iteration_two/usser/usserObject.dart';
import 'mocks.dart';

void main() {
  Widget createAddTaskScreen() {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<Usser>(create: (_) => MockUsser()),
        ChangeNotifierProvider<TaskProvider>(create: (_) => MockTaskProvider()),
        ChangeNotifierProvider<ProjectsProvider>(create: (_) => MockProjectsProvider()),
      ],
      child: const MaterialApp(
        home: Scaffold(body: AddTaskScreen()),
      ),
    );
  }

  testWidgets('Add Task screen renders without crashing', (WidgetTester tester) async {
    // Set a larger surface size to avoid overflow errors
    tester.view.physicalSize = const Size(1000, 1000);
    tester.view.devicePixelRatio = 1.0;
    
    await tester.pumpWidget(createAddTaskScreen());
    
    // Reset the surface size after the test
    addTearDown(() {
      tester.view.resetPhysicalSize();
    });
    
    expect(find.byType(AddTaskScreen), findsOneWidget);
  });

  testWidgets('Add Task screen displays message when no projects', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1000, 1000);
    tester.view.devicePixelRatio = 1.0;
    
    await tester.pumpWidget(createAddTaskScreen());
    await tester.pump(); // Allow for async rendering
    
    addTearDown(() {
      tester.view.resetPhysicalSize();
    });
    
    // Since our MockProjectsProvider has empty projects list, we should see this message
    expect(find.text('No projects available. Please create a project first.'), findsOneWidget);
  });
}