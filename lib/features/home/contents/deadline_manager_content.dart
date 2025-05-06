import 'package:flutter/material.dart';
import '../widgets/deadline_card.dart';

class DeadlineManagerContent extends StatelessWidget {
  final List<DeadlineItem> deadlines;
  final Function(DeadlineItem)? onDeadlineTap;

  const DeadlineManagerContent({
    Key? key,
    required this.deadlines,
    this.onDeadlineTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 80,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: deadlines.length,
        itemBuilder: (context, index) {
          final deadline = deadlines[index];
          return DeadlineCard(
            title: deadline.title,
            project: deadline.project,
            time: deadline.time,
            projectColor: deadline.color,
            onTap: () {
              if (onDeadlineTap != null) {
                onDeadlineTap!(deadline);
              }
            },
          );
        },
      ),
    );
  }
}

class DeadlineItem {
  final String title;
  final String project;
  final String time;
  final String? id;
  final String? projectId;
  final Color color;

  DeadlineItem({
    required this.title,
    required this.project,
    required this.time,
    this.id,
    this.projectId,
    this.color = Colors.grey,
  });
}
