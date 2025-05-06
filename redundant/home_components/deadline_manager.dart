// lib/features/home/widgets/deadline_manager.dart
import 'package:flutter/material.dart';

class DeadlineManager extends StatelessWidget {
  const DeadlineManager({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Upcoming Deadlines",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.calendar_today),
                  label: const Text("View Calendar"),
                ),
              ],
            ),
            Expanded(
              child: ListView(
                children: [
                  _buildDeadlineSection(context, "Today"),
                  const SizedBox(height: 16),
                  _buildDeadlineSection(context, "Tomorrow"),
                  const SizedBox(height: 16),
                  _buildDeadlineSection(context, "This Week"),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDeadlineSection(BuildContext context, String day) {
    // Sample deadline data
    final Map<String, List<_DeadlineItem>> deadlinesByDay = {
      "Today": [
        _DeadlineItem(
          title: "Submit Project Proposal",
          project: "Team Project",
          time: "2:00 PM",
        ),
        _DeadlineItem(
          title: "Review Pull Request",
          project: "Backend Development",
          time: "5:00 PM",
        ),
      ],
      "Tomorrow": [
        _DeadlineItem(
          title: "Team Meeting",
          project: "Team Project",
          time: "10:00 AM",
        ),
      ],
      "This Week": [
        _DeadlineItem(
          title: "Complete Frontend Tasks",
          project: "UI Design",
          time: "Friday, 3:00 PM",
        ),
        _DeadlineItem(
          title: "Database Implementation",
          project: "Backend Development",
          time: "Saturday, 12:00 PM",
        ),
      ],
    };

    final deadlines = deadlinesByDay[day] ?? [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          day,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        deadlines.isEmpty
            ? Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Text(
                  "No deadlines",
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontStyle: FontStyle.italic,
                  ),
                ),
              )
            : Wrap(
                spacing: 8,
                runSpacing: 8,
                children: deadlines
                    .map((deadline) => _buildDeadlineCard(context, deadline))
                    .toList(),
              ),
      ],
    );
  }

  Widget _buildDeadlineCard(BuildContext context, _DeadlineItem deadline) {
    return Container(
      width: 200,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            deadline.title,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          Text(
            deadline.project,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Icon(
                Icons.access_time,
                size: 14,
                color: Colors.grey[600],
              ),
              const SizedBox(width: 4),
              Text(
                deadline.time,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// Deadline data model
class _DeadlineItem {
  final String title;
  final String project;
  final String time;

  _DeadlineItem({
    required this.title,
    required this.project,
    required this.time,
  });
}
