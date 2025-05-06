import 'package:flutter/material.dart';
import '../../../../../../features/projects/models/project.dart';

class ProjectSummary extends StatelessWidget {
  final Project project;
  
  const ProjectSummary({
    Key? key,
    required this.project,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Project name [colored to match project]
          Text(
            project.name,
            style: theme.textTheme.titleLarge?.copyWith(
              color: project.colour,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          
          // Member count
          Text(
            'Total members: ${project.members.length}',
            style: TextStyle(
              color: theme.colorScheme.onSurface.withOpacity(0.7),
            ),
          ),
          const SizedBox(height: 4),
          
          // Overall progress [from project data]
          Row(
            children: [
              Icon(
                Icons.check_circle_outline,
                color: theme.colorScheme.primary,
                size: 16,
              ),
              const SizedBox(width: 4),
              Text(
                'Overall completion: ${project.progress.toStringAsFixed(0)}%',
                style: TextStyle(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          
          // Show more stats if lots of people or tasks
          if (project.members.length > 3 || project.totalTasks > 10) ...[
            const SizedBox(height: 12),
            _buildExtendedStats(theme),
          ],
        ],
      ),
    );
  }
  
  // More detailed stats for bigger projects
  Widget _buildExtendedStats(ThemeData theme) {
    // Some extra stats
    final daysLeft = project.daysRemaining;
    final hasDeadlineSoon = daysLeft < 7;
    
    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceVariant.withOpacity(0.3),
        borderRadius: BorderRadius.circular(8),
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Project deadline info [warning if close]
          Row(
            children: [
              Icon(
                hasDeadlineSoon ? Icons.warning : Icons.calendar_today,
                size: 14,
                color: hasDeadlineSoon ? Colors.orange : theme.colorScheme.onSurfaceVariant,
              ),
              const SizedBox(width: 4),
              Text(
                'Deadline in $daysLeft days',
                style: TextStyle(
                  color: hasDeadlineSoon ? Colors.orange : theme.colorScheme.onSurfaceVariant,
                  fontWeight: hasDeadlineSoon ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 8),
          
          // Task counts
          Row(
            children: [
              Icon(
                Icons.task_alt,
                size: 14,
                color: theme.colorScheme.onSurfaceVariant,
              ),
              const SizedBox(width: 4),
              Text(
                '${project.completedTasks} completed of ${project.totalTasks} tasks',
                style: TextStyle(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}