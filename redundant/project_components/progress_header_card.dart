import 'package:flutter/material.dart';
import 'info_section_container.dart';

class ProgressHeaderCard extends StatelessWidget {
  final int completedTasks;
  final int totalTasks;
  final Color progressColor;
  
  const ProgressHeaderCard({
    Key? key,
    required this.completedTasks,
    required this.totalTasks,
    required this.progressColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final progress = totalTasks > 0 ? completedTasks / totalTasks : 0.0;
    
    return InfoSectionContainer(
      icon: Icons.pie_chart,
      title: 'Progress',
      iconColor: progressColor,
      children: [
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(
                  value: progress,
                  minHeight: 10,
                  backgroundColor: Colors.grey[200],
                  valueColor: AlwaysStoppedAnimation<Color>(
                    progress > 0 ? progressColor : Colors.grey,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Text(
              '${(progress * 100).toInt()}%',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: progressColor,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '$completedTasks of $totalTasks tasks completed',
              style: TextStyle(
                color: Colors.grey[700],
                fontSize: 13,
              ),
            ),
            // Status indicator
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: _getStatusColor(progress).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                _getStatusText(progress),
                style: TextStyle(
                  color: _getStatusColor(progress),
                  fontWeight: FontWeight.w500,
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
  
  Color _getStatusColor(double progress) {
    if (progress >= 0.75) return Colors.green;
    if (progress >= 0.4) return Colors.blue;
    if (progress >= 0.1) return Colors.amber;
    return Colors.red;
  }
  
  String _getStatusText(double progress) {
    if (progress >= 0.75) return 'Almost Done';
    if (progress >= 0.4) return 'In Progress';
    if (progress >= 0.1) return 'Just Started';
    return 'Not Started';
  }
}
