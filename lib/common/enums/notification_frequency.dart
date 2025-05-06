// Common enum for notification frequency used across the application
enum NotificationFrequency { daily, weekly, monthly, none }

// Extension to provide human-readable names
extension NotificationFrequencyExtension on NotificationFrequency {
  String get name {
    switch (this) {
      case NotificationFrequency.daily:
        return 'Daily';
      case NotificationFrequency.weekly:
        return 'Weekly';
      case NotificationFrequency.monthly:
        return 'Monthly';
      case NotificationFrequency.none:
        return 'None';
      default:
        return '';
    }
  }
}
