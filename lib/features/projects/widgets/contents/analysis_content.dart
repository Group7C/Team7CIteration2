import 'package:flutter/material.dart';

class AnalysisContent extends StatelessWidget {
  final int completedTasks;
  final int totalTasks;
  
  const AnalysisContent({
    Key? key,
    required this.completedTasks,
    required this.totalTasks,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final progress = totalTasks > 0 ? completedTasks / totalTasks : 0.0;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 8),
        Row(
          children: [
            const Icon(
              Icons.check_circle_outline,
              size: 16,
              color: Colors.teal,
            ),
            const SizedBox(width: 6),
            Text(
              '$completedTasks / $totalTasks tasks completed',
              style: const TextStyle(
                fontSize: 13,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            const Icon(
              Icons.trending_up,
              size: 16,
              color: Colors.teal,
            ),
            const SizedBox(width: 6),
            Text(
              'Progress: ${(progress * 100).toInt()}%',
              style: const TextStyle(
                fontSize: 13,
              ),
            ),
          ],
        ),
      ],
    );
  }
  
  Color _getProgressColor(double progress) {
    if (progress >= 0.75) return Colors.green;
    if (progress >= 0.4) return Colors.blue;
    if (progress >= 0.1) return Colors.amber;
    return Colors.red;
  }
}
