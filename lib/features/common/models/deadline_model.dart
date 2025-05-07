class Deadline {
  final int projectUid;
  final String projectName;
  final DateTime date;
  final String? description;
  final bool isLate;

  Deadline({
    required this.projectUid,
    required this.projectName,
    required this.date,
    this.description,
  }) : isLate = DateTime.now().isAfter(date);

  // Calculate days remaining until deadline (negative if late)
  int get daysRemaining {
    final today = DateTime.now();
    final difference = date.difference(today).inDays;
    return difference;
  }

  // Format deadline status for display
  String get status {
    if (isLate) {
      return '${daysRemaining.abs()} days overdue';
    } else if (daysRemaining == 0) {
      return 'Due today';
    } else if (daysRemaining == 1) {
      return 'Due tomorrow';
    } else {
      return '$daysRemaining days remaining';
    }
  }
}
