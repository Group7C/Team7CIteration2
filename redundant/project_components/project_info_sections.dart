import 'package:flutter/material.dart';
import 'info_section_container.dart';
import 'package:intl/intl.dart';

class DeadlineInfoSection extends StatelessWidget {
  final DateTime deadline;
  
  const DeadlineInfoSection({
    Key? key,
    required this.deadline,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final daysRemaining = deadline.difference(DateTime.now()).inDays;
    final isOverdue = daysRemaining < 0;
    
    return InfoSectionContainer(
      icon: Icons.calendar_today,
      title: 'Deadline',
      iconColor: isOverdue ? Colors.red : Colors.blue,
      children: [
        const SizedBox(height: 8),
        Row(
          children: [
            Icon(
              isOverdue ? Icons.warning : Icons.event,
              size: 16,
              color: isOverdue ? Colors.red : Colors.blue,
            ),
            const SizedBox(width: 8),
            Text(
              DateFormat.yMMMd().format(deadline),
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 14,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 8,
            vertical: 4,
          ),
          decoration: BoxDecoration(
            color: isOverdue
                ? Colors.red.withOpacity(0.1)
                : daysRemaining < 7
                    ? Colors.orange.withOpacity(0.1)
                    : Colors.green.withOpacity(0.1),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(
            isOverdue
                ? 'Overdue by ${-daysRemaining} days'
                : '$daysRemaining days remaining',
            style: TextStyle(
              fontSize: 12,
              color: isOverdue
                  ? Colors.red
                  : daysRemaining < 7
                      ? Colors.orange
                      : Colors.green,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}

class MeetingsInfoSection extends StatelessWidget {
  final VoidCallback? onScheduleMeeting;
  final String? lastMeetingDate;
  final String? nextMeetingDate;
  
  const MeetingsInfoSection({
    Key? key,
    this.onScheduleMeeting,
    this.lastMeetingDate,
    this.nextMeetingDate,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InfoSectionContainer(
      icon: Icons.groups,
      title: 'Meetings',
      iconColor: Colors.blue,
      actionLabel: 'Schedule',
      actionIcon: Icons.calendar_month,
      onAction: onScheduleMeeting,
      children: [
        const SizedBox(height: 8),
        Row(
          children: [
            Icon(
              Icons.event_available,
              size: 16,
              color: Colors.blue[600],
            ),
            const SizedBox(width: 6),
            Text(
              'Last meeting: ${lastMeetingDate ?? 'None'}',
              style: const TextStyle(
                fontSize: 13,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Icon(
              Icons.upcoming,
              size: 16,
              color: Colors.blue[600],
            ),
            const SizedBox(width: 6),
            Text(
              nextMeetingDate != null 
                  ? 'Next: $nextMeetingDate' 
                  : 'No upcoming meetings',
              style: TextStyle(
                fontSize: 13,
                color: nextMeetingDate != null 
                    ? Colors.black87 
                    : Colors.grey[600],
                fontStyle: nextMeetingDate != null 
                    ? FontStyle.normal 
                    : FontStyle.italic,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class AnalysisInfoSection extends StatelessWidget {
  final int completedTasks;
  final int totalTasks;
  final VoidCallback? onGenerateReport;
  
  const AnalysisInfoSection({
    Key? key,
    required this.completedTasks,
    required this.totalTasks,
    this.onGenerateReport,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final progress = totalTasks > 0 ? completedTasks / totalTasks : 0.0;
    
    return InfoSectionContainer(
      icon: Icons.analytics,
      title: 'Analysis',
      iconColor: Colors.teal,
      actionLabel: 'Report',
      actionIcon: Icons.assessment,
      onAction: onGenerateReport,
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
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(2),
          child: LinearProgressIndicator(
            value: progress,
            minHeight: 4,
            backgroundColor: Colors.grey[200],
            valueColor: AlwaysStoppedAnimation<Color>(
              _getProgressColor(progress),
            ),
          ),
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
