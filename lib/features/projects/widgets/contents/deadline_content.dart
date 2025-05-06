import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DeadlineContent extends StatelessWidget {
  final DateTime deadline;
  
  const DeadlineContent({
    Key? key,
    required this.deadline,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final daysRemaining = deadline.difference(DateTime.now()).inDays;
    final isOverdue = daysRemaining < 0;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
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
