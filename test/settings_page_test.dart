import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:sevenc_iteration_two/Objects/task.dart';
import 'package:sevenc_iteration_two/home/settings_page.dart';
import 'package:sevenc_iteration_two/providers/theme_provider.dart';
import 'package:sevenc_iteration_two/usser/usserObject.dart';

class MockUsser extends ChangeNotifier implements Usser {
  @override
  String get usserName => _usserName;
  String _usserName = "TestUser";

  @override
  String get email => _email;
  String _email = "test@example.com";

  @override
  int get currancyTotal => _currancyTotal;
  int _currancyTotal = 100;

  @override
  String? get profilePic => _profilePic;
  String? _profilePic;

  @override
  set usserName(String value) {
    _usserName = value;
    notifyListeners();
  }

  @override
  set email(String value) {
    _email = value;
    notifyListeners();
  }

  @override
  set currancyTotal(int value) {
    _currancyTotal = value;
    notifyListeners();
  }

  @override
  set profilePic(String? value) {
    _profilePic = value;
    notifyListeners();
  }

  @override
  late Map<String, dynamic> settings = {};

  @override
  late List<dynamic> tasks = [];

  @override
  late String theme = "light";

  @override
  late Map<int, String> usserData = {};

  @override
  late String usserID = "mock-id";

  @override
  late String usserPassword = "mock-password";

  MockUsser() {
    loadMockTasks(); // load tasks during construction
  }

  void loadMockTasks() {
    List<dynamic> jsonData = [
      {
        'title': 'Mock Task',
        'description': 'This is a mock task for testing.',
        'status': 'inProgress',
        'priority': 1,
        'percentageWeighting': 50,
        'listOfTags': ['urgent', 'work'],
        'startDate': '2024-01-01T00:00:00.000',
        'endDate': '2024-01-07T00:00:00.000',
        'parentProject': 'mock_project',
        'members': {'mockUser': 'owner'},
        'notificationPreference': true,
        'notificationFrequency': 'daily',
      }
    ];

    List<Task> parsedTasks = [];
    for (var item in jsonData) {
      Status taskStatus;
      switch (item['status']) {
        case 'inProgress':
          taskStatus = Status.inProgress;
          break;
        case 'completed':
          taskStatus = Status.completed;
          break;
        default:
          taskStatus = Status.todo;
      }

      NotificationFrequency notificationFreq;
      switch (item['notificationFrequency']) {
        case 'weekly':
          notificationFreq = NotificationFrequency.weekly;
          break;
        case 'monthly':
          notificationFreq = NotificationFrequency.monthly;
          break;
        case 'none':
          notificationFreq = NotificationFrequency.none;
          break;
        default:
          notificationFreq = NotificationFrequency.daily;
      }

      parsedTasks.add(Task(
        title: item['title'],
        description: item['description'],
        status: taskStatus,
        priority: item['priority'],
        percentageWeighting: item['percentageWeighting'],
        listOfTags: List<String>.from(item['listOfTags']),
        startDate: DateTime.parse(item['startDate']),
        endDate: DateTime.parse(item['endDate']),
        parentProject: item['parentProject'],
        members: Map<String, String>.from(item['members']),
        notificationPreference: item['notificationPreference'],
        notificationFrequency: notificationFreq,
        directoryPath: 'offline/tasks/${item['title']}',
      ));
    }

    tasks = parsedTasks;
  }

  @override
  Future<void> changeTheme() async {}

  @override
  Future<bool?> checkUsserExists() async => true;

  @override
  Future<String> getID() async => usserID;

  @override
  Future<String?> getPassword() async => usserPassword;

  @override
  Future<String> getProjects() async => "mock-projects";

  @override
  Future<List<Task>> getTasksAsync() async => tasks.cast<Task>();

  @override
  Future<String?> getTheme() async => theme;

  @override
  Future<bool?> passwordCorrect() async => true;

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
