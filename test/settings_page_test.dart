import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:sevenc_iteration_two/home/settings_page.dart';
import 'package:sevenc_iteration_two/providers/theme_provider.dart';
import 'package:sevenc_iteration_two/usser/usserObject.dart';

// Jamie's settings page testing

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
    // Don't need task loading for settings page tests
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
  Future<List> getTasksAsync() async => tasks;

  @override
  Future<String?> getTheme() async => theme;

  @override
  Future<bool?> passwordCorrect() async => true;

  // Implementation for the missing methods
  @override
  Future<void> updateUsername() async {
    // Mock implementation
    return Future.value();
  }

  @override
  void updateUsser() {
    // Mock implementation
  }

  @override
  Future<void> uploadUsser() async {
    // Mock implementation
    return Future.value();
  }
}

void main() {
  group("SettingsPage widget tests", () {
    late ThemeProvider themeProvider;
    late MockUsser mockUsser;

    setUp(() {
      themeProvider = ThemeProvider();
      mockUsser = MockUsser();
    });

    testWidgets("displays settings title and theme options",
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider<ThemeProvider>.value(value: themeProvider),
            ChangeNotifierProvider<Usser>.value(value: mockUsser),
          ],
          child: MaterialApp(
            home: SettingsPage(),
          ),
        ),
      );

      // Check for title and theme selection
      expect(
          find.text("Settings"), findsWidgets); // One in AppBar, one as header
      expect(find.text("Select Theme"), findsOneWidget);
      expect(find.text("Light Theme"), findsOneWidget);
      expect(find.text("Dark Theme"), findsOneWidget);
      expect(find.text("Custom Theme"), findsOneWidget);
    });

    testWidgets("can select a different theme", (WidgetTester tester) async {
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider<ThemeProvider>.value(value: themeProvider),
            ChangeNotifierProvider<Usser>.value(value: mockUsser),
          ],
          child: MaterialApp(
            home: SettingsPage(),
          ),
        ),
      );

      // Get the initial theme text
      final themeSelectorFinder = find.byType(ListTile).first;
      expect(themeSelectorFinder, findsOneWidget);

      // Tap Dark Theme option
      await tester.tap(find.text("Dark Theme"));
      await tester.pumpAndSettle();

      // Verify theme is set to Dark
      expect(themeProvider.themeType, equals(ThemeType.dark));
      // Additional verification by finding the RadioListTile that's selected
      final darkRadioTile = tester.widget<RadioListTile<ThemeType>>(
        find.ancestor(
          of: find.text("Dark Theme"),
          matching: find.byType(RadioListTile<ThemeType>),
        ),
      );
      expect(darkRadioTile.groupValue, equals(ThemeType.dark));
    });

    testWidgets("shows custom theme options when Custom is selected",
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider<ThemeProvider>.value(value: themeProvider),
            ChangeNotifierProvider<Usser>.value(value: mockUsser),
          ],
          child: MaterialApp(
            home: SettingsPage(),
          ),
        ),
      );

      // Custom theme options shouldn't be visible initially
      expect(find.text("Surface Color"), findsNothing);
      expect(find.text("Text Color"), findsNothing);

      // Tap Custom Theme option
      await tester.tap(find.text("Custom Theme"));
      await tester.pumpAndSettle();

      // Now custom options should be visible
      expect(find.text("Surface Color"), findsOneWidget);
      expect(find.text("Text Color"), findsOneWidget);
    });
  });
}
