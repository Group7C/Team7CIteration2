import 'package:flutter/material.dart';

/// Utility class for theme-related helper functions
class ThemeUtils {
  /// Gets the appropriate color for a card background based on theme
  static Color getCardColor(BuildContext context) {
    return Theme.of(context).colorScheme.surface;
  }
  
  /// Gets the appropriate color for text based on theme
  static Color getTextColor(BuildContext context) {
    return Theme.of(context).colorScheme.onSurface;
  }
  
  /// Gets the appropriate color for secondary text based on theme
  static Color getSecondaryTextColor(BuildContext context) {
    return Theme.of(context).colorScheme.onSurfaceVariant;
  }
  
  /// Gets the appropriate color for primary actions (buttons, links, etc.)
  static Color getPrimaryColor(BuildContext context) {
    return Theme.of(context).colorScheme.primary;
  }
  
  /// Gets the appropriate color for the background
  static Color getBackgroundColor(BuildContext context) {
    return Theme.of(context).colorScheme.surfaceDim;
  }
  
  /// Gets the appropriate color for borders and dividers
  static Color getDividerColor(BuildContext context) {
    return Theme.of(context).colorScheme.outline.withOpacity(0.5);
  }
  
  /// Gets color based on task status (to_do, in_progress, complete)
  static Color getStatusColor(BuildContext context, String status) {
    final theme = Theme.of(context);
    switch (status) {
      case 'complete':
        return Colors.green;
      case 'in_progress':
        return Colors.orange;
      case 'to_do':
      default:
        return theme.colorScheme.primary;
    }
  }
  
  /// Gets the appropriate card decoration based on theme
  static BoxDecoration getCardDecoration(BuildContext context) {
    final theme = Theme.of(context);
    return BoxDecoration(
      color: theme.colorScheme.surface,
      borderRadius: BorderRadius.circular(8),
      border: Border.all(
        color: theme.colorScheme.outline.withOpacity(0.5),
        width: 1,
      ),
    );
  }
}