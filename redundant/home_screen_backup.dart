import 'package:flutter/material.dart';
import '../containers/home_card_container.dart';
import '../managers/home_content_manager.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          // Top row - three equal cards for main navigation [projects/groups/activity]
          Expanded(
            flex: 2,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Projects card [shows active projects with progress]
                Expanded(
                  child: HomeCardContainer(
                    title: "Projects",
                    actionButton: IconButton(
                      icon: const Icon(Icons.add),
                      onPressed: () {
                        // TODO: Implement project creation modal
                      },
                    ),
                    content: HomeContentManager.buildProjectsListContent(
                      onProjectTap: (project) {
                        // Temp navigation - will link to proper project screen later
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Navigate to ${project.name}'),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                
                // Groups card [shows teams user belongs to]
                Expanded(
                  child: HomeCardContainer(
                    title: "Groups",
                    actionButton: IconButton(
                      icon: const Icon(Icons.add),
                      onPressed: () {
                        // TODO: Implement group creation flow
                      },
                    ),
                    content: HomeContentManager.buildGroupsListContent(
                      onGroupTap: (group) {
                        // Temp navigation - will connect to proper group screen
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Navigate to ${group.name}'),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                
                // Activity feed [shows chronological team activity]
                Expanded(
                  child: HomeCardContainer(
                    title: "Recent Activity",
                    content: HomeContentManager.buildActivityTrackerContent(),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          
          // Middle row - personal task kanban [largest section for task management]
          Expanded(
            flex: 3,
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "My Tasks",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Expanded(
                      child: HomeContentManager.buildKanbanBoardContent(),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          
          // Bottom row - deadline timeline [shows upcoming due dates]
          Expanded(
            flex: 2,
            child: Card(
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
                          onPressed: () {
                            // TODO: Connect to proper calendar view
                          },
                          icon: const Icon(Icons.calendar_today),
                          label: const Text("View Calendar"),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Expanded(
                      child: HomeContentManager.buildDeadlineManagerContent(),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
