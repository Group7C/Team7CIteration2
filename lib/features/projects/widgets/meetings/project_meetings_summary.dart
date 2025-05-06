import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/project.dart';

/// Widget that displays the next and last meeting dates for a project
class ProjectMeetingsSummary extends StatelessWidget {
  final Project project;
  final VoidCallback? onTapScheduleMeeting;
  
  const ProjectMeetingsSummary({
    Key? key,
    required this.project,
    this.onTapScheduleMeeting,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: theme.colorScheme.primary.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title with icon
            Row(
              children: [
                Icon(
                  Icons.groups_rounded,
                  color: theme.colorScheme.primary,
                  size: 24,
                ),
                const SizedBox(width: 8),
                Text(
                  'Meetings',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.primary,
                  ),
                ),
                const Spacer(),
                // Schedule meeting button
                if (onTapScheduleMeeting != null)
                  TextButton.icon(
                    onPressed: onTapScheduleMeeting,
                    icon: const Icon(Icons.event_available, size: 18),
                    label: const Text('Schedule'),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                  ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Next meeting section
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Next Meeting:',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                _buildDateInfo(
                  context,
                  project.nextMeetingDate,
                  'No upcoming meetings scheduled',
                  theme.colorScheme.secondary,
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Last meeting section
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Last Meeting:',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                _buildDateInfo(
                  context,
                  project.lastMeetingDate,
                  'No previous meetings recorded',
                  theme.colorScheme.error,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildDateInfo(
    BuildContext context,
    DateTime? date,
    String emptyMessage,
    Color accentColor,
  ) {
    if (date == null) {
      return Text(
        emptyMessage,
        style: TextStyle(
          fontStyle: FontStyle.italic,
          color: Colors.grey[600],
        ),
      );
    }
    
    final now = DateTime.now();
    final difference = date.difference(now).inDays;
    
    String relativeDate;
    if (difference > 0) {
      relativeDate = difference == 1 ? 'Tomorrow' : 'In $difference days';
    } else if (difference < 0) {
      final absDiff = difference.abs();
      relativeDate = absDiff == 1 ? 'Yesterday' : '$absDiff days ago';
    } else {
      relativeDate = 'Today';
    }
    
    return Row(
      children: [
        Icon(
          date.isAfter(now) ? Icons.event_available : Icons.event_note,
          size: 18,
          color: accentColor,
        ),
        const SizedBox(width: 8),
        Text(
          DateFormat.yMMMd().format(date),
          style: TextStyle(
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
            color: accentColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            relativeDate,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: accentColor,
            ),
          ),
        ),
      ],
    );
  }
}