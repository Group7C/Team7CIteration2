class ProgressCalculator {
  /// Calculates project progress percentage based on completed tasks
  static double calculateProgress(int completedTasks, int totalTasks) {
    if (totalTasks == 0) return 0.0;
    return completedTasks / totalTasks;
  }
  
  /// Returns appropriate color based on progress percentage
  static int getProgressColor(double progress) {
    if (progress < 0.3) {
      return 0xFFE53935; // Red
    } else if (progress < 0.7) {
      return 0xFFFFC107; // Amber
    } else {
      return 0xFF4CAF50; // Green
    }
  }
}
