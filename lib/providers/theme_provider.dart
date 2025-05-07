import 'package:flutter/material.dart';
import 'package:sevenc_iteration_two/Themes.dart';

enum ThemeType { light, dark, custom } // Define three theme types

class ThemeProvider with ChangeNotifier {
  ThemeType _themeType = ThemeType.dark; // Default theme mode
  Color? _surfaceColor; 
  Color? _onSurfaceColor;

  ThemeData get currentTheme {
    switch (_themeType) {
      case ThemeType.light:
        return AppTheme(TextTheme()).light();
      case ThemeType.dark:
        return AppTheme(TextTheme()).dark();
      case ThemeType.custom:
        // Ensure custom colors are passed correctly
        if (_surfaceColor != null && _onSurfaceColor != null) {
          // Calling AppTheme.custom() with primaryColor and accentColor as arguments
          return AppTheme(TextTheme()).custom(_surfaceColor!, _onSurfaceColor!);
        } else {
          return AppTheme(TextTheme()).dark(); // Fallback to dark theme if no custom colors are set
        }
      default:
        return AppTheme(TextTheme()).dark(); // Default to dark theme if none selected
    }
  }
    ThemeMode get themeMode {
    switch (_themeType) {
      case ThemeType.light:
        return ThemeMode.light;
      case ThemeType.dark:
        return ThemeMode.dark;
      case ThemeType.custom:
        return ThemeMode.light; // Custom themes use light/dark mode as base
    }
  }

  ThemeType get themeType => _themeType;

  void setTheme(ThemeType theme) {
    _themeType = theme;
    notifyListeners();
  }

  // Update custom theme colors with more properties
  void setCustomTheme({required Color surfaceColor, required Color onSurfaceColor}) {
    _surfaceColor = surfaceColor;
    _onSurfaceColor = onSurfaceColor;
    
    // Adjust the ColorScheme based on surface brightness
    final bool isDark = ThemeData.estimateBrightnessForColor(surfaceColor) == Brightness.dark;
    
    // Store the theme type
    _themeType = ThemeType.custom;
    
    notifyListeners();
  }

  void toggleTheme() {
  if (_themeType == ThemeType.dark) {
    setTheme(ThemeType.light);
  } else if (_themeType == ThemeType.light) {
    setTheme(ThemeType.custom);
  } else {
    setTheme(ThemeType.dark);
  }
}
}
