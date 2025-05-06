import 'package:flutter/material.dart';

class ActivityTrackerContent extends StatelessWidget {
  final List<ActivityItem> activities;

  const ActivityTrackerContent({
    Key? key,
    required this.activities,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: activities.length,
      itemBuilder: (context, index) {
        return _buildActivityItem(context, activities[index]);
      },
    );
  }

  Widget _buildActivityItem(BuildContext context, ActivityItem activity) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: activity.color.withOpacity(0.2),
        child: Icon(activity.icon, color: activity.color, size: 20),
      ),
      title: Text(activity.description),
      subtitle: Text(activity.timeAgo),
      dense: true,
    );
  }
}

class ActivityItem {
  final String description;
  final String timeAgo;
  final IconData icon;
  final Color color;
  final String? id;

  ActivityItem({
    required this.description,
    required this.timeAgo,
    required this.icon,
    required this.color,
    this.id,
  });
}
