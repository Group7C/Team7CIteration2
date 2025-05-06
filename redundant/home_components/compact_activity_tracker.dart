// lib/features/home/widgets/compact_activity_tracker.dart
import 'package:flutter/material.dart';

class CompactActivityTracker extends StatelessWidget {
  const CompactActivityTracker({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Recent Activity",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: 5,
                itemBuilder: (context, index) {
                  return _buildActivityItem(context, index);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActivityItem(BuildContext context, int index) {
    // Sample activity data
    final activities = [
      "John completed a task",
      "Sarah joined the project",
      "Mike updated the design",
      "Emma added a new document",
      "Alex commented on a task"
    ];
    final times = ["1 hour ago", "2 hours ago", "Yesterday", "Yesterday", "2 days ago"];
    final icons = [
      Icons.task_alt,
      Icons.person_add,
      Icons.design_services,
      Icons.file_present,
      Icons.comment
    ];
    final colors = [
      Colors.green,
      Colors.blue,
      Colors.purple,
      Colors.amber,
      Colors.teal
    ];

    return ListTile(
      leading: CircleAvatar(
        backgroundColor: colors[index].withOpacity(0.2),
        child: Icon(icons[index], color: colors[index], size: 20),
      ),
      title: Text(activities[index]),
      subtitle: Text(times[index]),
      dense: true,
    );
  }
}
