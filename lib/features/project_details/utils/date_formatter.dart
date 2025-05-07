class DateFormatter {
  /// Formats a date to DD/MM/YYYY format - UK style
  static String formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
  
  /// Calculates days remaining from today to the given date
  static int getDaysRemaining(DateTime deadline) {
    final now = DateTime.now();
    return deadline.difference(now).inDays;
  }
}
