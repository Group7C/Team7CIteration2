import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:sevenc_iteration_two/Objects/task.dart';
import 'package:sevenc_iteration_two/home/settings_page.dart';
import 'package:sevenc_iteration_two/providers/theme_provider.dart';
import 'package:sevenc_iteration_two/usser/usserObject.dart';

class MockUsser extends ChangeNotifier implements Usser {
  @override
  String get usserName => "TestUser";

  @override
  String get email => "test@example.com";

  @override
  int get currancyTotal => 100;

  @override
  String? get profilePic => null;

  @override
  late Map<String, dynamic> settings;

  @override
  late List tasks;

  @override
  late String theme;

  @override
  late Map<int, String> usserData;

  @override
  late String usserID;

  @override
  late String usserPassword;

  @override
  Future<void> changeTheme() {
    // TODO: implement changeTheme
    throw UnimplementedError();
  }

  @override
  Future<bool?> checkUsserExists() {
    // TODO: implement checkUsserExists
    throw UnimplementedError();
  }

  @override
  set currancyTotal(int _currancyTotal) {
    // TODO: implement currancyTotal
  }

  @override
  set email(String _email) {
    // TODO: implement email
  }

  @override
  Future<String> getID() {
    // TODO: implement getID
    throw UnimplementedError();
  }

  @override
  Future<String?> getPassword() {
    // TODO: implement getPassword
    throw UnimplementedError();
  }

  @override
  Future<String> getProjects() {
    // TODO: implement getProjects
    throw UnimplementedError();
  }

  @override
  Future<List<Task>> getTasksAsync() {
    // TODO: implement getTasksAsync
    throw UnimplementedError();
  }

  @override
  Future<String?> getTheme() {
    // TODO: implement getTheme
    throw UnimplementedError();
  }

  @override
  Future<bool?> passwordCorrect() {
    // TODO: implement passwordCorrect
    throw UnimplementedError();
  }

  @override
  set profilePic(String? _profilePic) {
    // TODO: implement profilePic
  }

  @override
  Future<void> updateUsername() {
    // TODO: implement updateUsername
    throw UnimplementedError();
  }

  @override
  void updateUsser() {
    // TODO: implement updateUsser
  }

  @override
  Future<void> uploadUsser() {
    // TODO: implement uploadUsser
    throw UnimplementedError();
  }

  @override
  set usserName(String _usserName) {
    // TODO: implement usserName
  }

// Implement other required methods or fields with dummies if needed
}

void main() {
  group("SettingsPage widget tests", () {
    late ThemeProvider themeProvider;
    late MockUsser mockUsser;

    setUp(() {
      themeProvider = ThemeProvider();
      mockUsser = MockUsser();
    });

    testWidgets("displays user info and currency", (WidgetTester tester) async {
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider<ThemeProvider>.value(value: themeProvider),
            ChangeNotifierProvider<Usser>.value(value: mockUsser),
          ],
          child: const MaterialApp(
            home: SettingsPage(),
          ),
        ),
      );

      // Check if username, email, and currency are shown
      expect(find.text("TestUser"), findsOneWidget);
      expect(find.text("test@example.com"), findsOneWidget);
      expect(find.text("100"), findsWidgets); // currency appears twice
    });

    testWidgets("toggles theme options when button is pressed", (WidgetTester tester) async {
      print("Building test UI");
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider<ThemeProvider>.value(value: themeProvider),
            ChangeNotifierProvider<Usser>.value(value: mockUsser),
          ],
          child: const MaterialApp(
            home: SettingsPage(),
          ),
        ),
      );

      print("Tapping Themes button...");
      await tester.tap(find.text("Themes"));
      await tester.pumpAndSettle();
      print("Tapped.");

      expect(find.text("Current Theme"), findsOneWidget);
      expect(find.text("Light Theme"), findsOneWidget);
      expect(find.text("Dark Theme"), findsOneWidget);
      expect(find.text("Custom Theme"), findsOneWidget);
    });

    testWidgets("shows logout and documentation buttons", (WidgetTester tester) async {
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider<ThemeProvider>.value(value: themeProvider),
            ChangeNotifierProvider<Usser>.value(value: mockUsser),
          ],
          child: const MaterialApp(
            home: SettingsPage(),
          ),
        ),
      );

      // Check for logout and documentation buttons
      expect(find.text("Logout"), findsOneWidget);
      expect(find.text("Documentation"), findsOneWidget);
    });
  });
}
