// lib/home/components/activity_tracker/activity_tracker.dart
import 'package:flutter/material.dart';
import 'activity_item.dart';

class ActivityTracker extends StatelessWidget {
  const ActivityTracker({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      color: colorScheme.surface,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Recent Activity",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                itemCount: 5,
                itemBuilder: (context, index) {
                  return ActivityItem(
                    userName: "John Doe",
                    action: "completed a task",
                    timeAgo: "${index + 1} hours ago",
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
