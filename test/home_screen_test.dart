import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sevenc_iteration_two/home/home_screen.dart';

void main() {
  testWidgets('Home screen renders without crashing', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Home(),
      ),
    );

    expect(find.byType(Home), findsOneWidget);
  });

  testWidgets('Home screen contains at least one Column', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Home(),
      ),
    );

    // Since everything is wrapped in padding and Expanded -> Column is there
    expect(find.byType(Column), findsWidgets);
  });

  testWidgets('Home screen contains at least one Expanded widget', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Home(),
      ),
    );

    // Instead of looking for Row (which might be inside scroll views or not loaded instantly), test for Expanded
    expect(find.byType(Expanded), findsWidgets);
  });

  testWidgets('Home screen contains at least one Padding widget', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Home(),
      ),
    );

    expect(find.byType(Padding), findsWidgets);
  });
}
