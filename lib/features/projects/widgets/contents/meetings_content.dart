import 'package:flutter/material.dart';

class MeetingsContent extends StatelessWidget {
  final String? lastMeetingDate;
  final String? nextMeetingDate;
  
  const MeetingsContent({
    Key? key,
    this.lastMeetingDate,
    this.nextMeetingDate,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Simple direct display of the values provided
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
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
              'Last meeting: ${lastMeetingDate ?? "Not recorded"}',
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
                // Use the same default color as the "Last meeting" text
                // No explicit color setting will use theme's text color
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
