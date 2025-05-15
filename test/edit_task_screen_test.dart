import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:sevenc_iteration_two/tasks/edit_task_screen.dart';
import 'package:sevenc_iteration_two/providers/tasks_provider.dart';
import 'package:sevenc_iteration_two/providers/projects_provider.dart';
import 'package:sevenc_iteration_two/usser/usserObject.dart';
import 'mocks.dart';

void main() {
  Widget createEditTaskScreen() {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<Usser>(create: (_) => MockUsser()),
        ChangeNotifierProvider<TaskProvider>(create: (_) => MockTaskProvider()),
        ChangeNotifierProvider<ProjectsProvider>(create: (_) => MockProjectsProvider()),
      ],
      child: const MaterialApp(
        home: Scaffold(body: EditTaskScreen()),
      ),
    );
  }

  testWidgets('Edit Task screen renders without crashing', (WidgetTester tester) async {
    // Set a larger surface size to avoid overflow errors
    tester.view.physicalSize = const Size(1000, 1000);
    tester.view.devicePixelRatio = 1.0;
    
    await tester.pumpWidget(createEditTaskScreen());
    
    // Reset the surface size after the test
    addTearDown(() {
      tester.view.resetPhysicalSize();
    });
    
    expect(find.byType(EditTaskScreen), findsOneWidget);
  });

  testWidgets('Edit Task screen displays message when no tasks', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1000, 1000);
    tester.view.devicePixelRatio = 1.0;
    
    await tester.pumpWidget(createEditTaskScreen());
    await tester.pump(); // Allow for async rendering
    
    addTearDown(() {
      tester.view.resetPhysicalSize();
    });
    
    // Since our MockTaskProvider has empty tasks list, we should see this message
    expect(find.text('No tasks available to edit. Loading...'), findsOneWidget);
  });
}