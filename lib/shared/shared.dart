import 'package:flutter/material.dart';
import 'components/home/projects.dart';
import 'components/home/groups.dart';
import 'components/home/details.dart';
import 'components/project/progress.dart';
import 'components/project/details.dart';
import 'components/project/members.dart';
import 'components/project/meetings.dart';

class SharedScreen extends StatefulWidget {
  const SharedScreen({super.key});

  @override
  State<SharedScreen> createState() => _SharedScreenState();
}

class _SharedScreenState extends State<SharedScreen> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header section
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  Icon(
                    Icons.science,
                    size: 48,
                    color: colorScheme.onPrimaryContainer,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Shared Components',
                    style: theme.textTheme.headlineMedium?.copyWith(
                      color: colorScheme.onPrimaryContainer,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'A collection of shared components for testing',
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: colorScheme.onPrimaryContainer.withOpacity(0.8),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            
            // Home Components section
            Text(
              'Home Components',
              style: theme.textTheme.headlineSmall,
            ),
            const SizedBox(height: 16),
            LayoutBuilder(
              builder: (context, constraints) {
                final itemWidth = (constraints.maxWidth - 32) / 3; // 32 = 2 * 16px spacing
                return Row(
                  children: const [
                    Expanded(
                      child: ProjectsComponent(),
                    ),
                    SizedBox(width: 16),
                    Expanded(
                      child: GroupsComponent(),
                    ),
                    SizedBox(width: 16),
                    Expanded(
                      child: DetailsComponent(),
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: 32),
            
            // Project Components section
            Text(
              'Project Components',
              style: theme.textTheme.headlineSmall,
            ),
            const SizedBox(height: 16),
            LayoutBuilder(
              builder: (context, constraints) {
                final itemWidth = (constraints.maxWidth - 48) / 4; // 48 = 3 * 16px spacing
                return Row(
                  children: const [
                    Expanded(
                      child: ProgressComponent(),
                    ),
                    SizedBox(width: 16),
                    Expanded(
                      child: ProjectDetailsComponent(),
                    ),
                    SizedBox(width: 16),
                    Expanded(
                      child: MembersComponent(),
                    ),
                    SizedBox(width: 16),
                    Expanded(
                      child: MeetingsComponent(),
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
