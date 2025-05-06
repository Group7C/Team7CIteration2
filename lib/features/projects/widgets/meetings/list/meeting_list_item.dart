import 'package:flutter/material.dart';
import '../../../../../models/meetings/meeting.dart';

/// Display a single meeting in a list [meeting card/item]
class MeetingListItem extends StatelessWidget {
  final Meeting meeting;
  final VoidCallback? onTap;
  
  const MeetingListItem({
    Key? key,
    required this.meeting,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Meeting title and date
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      meeting.title ?? 'Meeting on ${meeting.formattedDate}',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Text(
                    meeting.formattedDate,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.6),
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 8),
              
              // Attendance info
              Row(
                children: [
                  Icon(
                    Icons.people,
                    size: 16,
                    color: theme.colorScheme.secondary,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${meeting.presentAttendees}/${meeting.totalAttendees} attended',
                    style: theme.textTheme.bodySmall,
                  ),
                  const SizedBox(width: 16),
                  
                  // Attendance percentage bar
                  Expanded(
                    child: Stack(
                      children: [
                        // Background bar
                        Container(
                          height: 6,
                          decoration: BoxDecoration(
                            color: theme.colorScheme.surfaceVariant,
                            borderRadius: BorderRadius.circular(3),
                          ),
                        ),
                        // Filled portion
                        FractionallySizedBox(
                          widthFactor: meeting.attendancePercentage / 100,
                          child: Container(
                            height: 6,
                            decoration: BoxDecoration(
                              color: _getAttendanceColor(meeting.attendancePercentage, theme),
                              borderRadius: BorderRadius.circular(3),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(width: 8),
                  
                  // Percentage text
                  Text(
                    '${meeting.attendancePercentage.toStringAsFixed(0)}%',
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: _getAttendanceColor(meeting.attendancePercentage, theme),
                    ),
                  ),
                ],
              ),
              
              // Show notes preview if available
              if (meeting.hasNotes) ...[
                const SizedBox(height: 12),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.note,
                      size: 16,
                      color: theme.colorScheme.primary.withOpacity(0.7),
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        meeting.notes!,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurface.withOpacity(0.7),
                          fontStyle: FontStyle.italic,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
  
  // Get color based on attendance percentage
  Color _getAttendanceColor(double percentage, ThemeData theme) {
    if (percentage >= 80) {
      return Colors.green;
    } else if (percentage >= 50) {
      return Colors.amber;
    } else {
      return theme.colorScheme.error;
    }
  }
}