import 'package:flutter/material.dart';
import '../containers/home_card_container.dart';
import '../managers/home_content_manager.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Future<Widget> _projectsContent;
  late Future<Widget> _groupsContent;
  late Future<Widget> _activityContent;
  late Future<Widget> _kanbanContent;
  late Future<Widget> _deadlinesContent;
  
  @override
  void initState() {
    super.initState();
    _loadData();
  }
  
  void _loadData() {
    setState(() {
      _projectsContent = HomeContentManager.buildProjectsListContent(
        onProjectTap: (project) {
          // Navigate to project details
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Navigate to ${project.name}'),
            ),
          );
        },
      );
      
      _groupsContent = HomeContentManager.buildGroupsListContent(
        onGroupTap: (group) {
          // Navigate to group details
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Navigate to ${group.name}'),
            ),
          );
        },
      );
      
      _activityContent = HomeContentManager.buildActivityTrackerContent();
      _kanbanContent = HomeContentManager.buildKanbanBoardContent();
      _deadlinesContent = HomeContentManager.buildDeadlineManagerContent();
    });
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async {
        _loadData();
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              // Top row - three equal cards for main navigation [projects/groups/activity]
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.22,
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
                        content: FutureBuilder<Widget>(
                          future: _projectsContent,
                          builder: (context, snapshot) {
                            if (snapshot.connectionState == ConnectionState.waiting) {
                              return const Center(child: CircularProgressIndicator());
                            } else if (snapshot.hasError) {
                              return Center(child: Text('Error: ${snapshot.error}'));
                            } else {
                              return snapshot.data ?? const Center(child: Text('No projects'));
                            }
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
                        content: FutureBuilder<Widget>(
                          future: _groupsContent,
                          builder: (context, snapshot) {
                            if (snapshot.connectionState == ConnectionState.waiting) {
                              return const Center(child: CircularProgressIndicator());
                            } else if (snapshot.hasError) {
                              return Center(child: Text('Error: ${snapshot.error}'));
                            } else {
                              return snapshot.data ?? const Center(child: Text('No groups'));
                            }
                          },
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    
                    // Activity feed [shows chronological team activity]
                    Expanded(
                      child: HomeCardContainer(
                        title: "Recent Activity",
                        content: FutureBuilder<Widget>(
                          future: _activityContent,
                          builder: (context, snapshot) {
                            if (snapshot.connectionState == ConnectionState.waiting) {
                              return const Center(child: CircularProgressIndicator());
                            } else if (snapshot.hasError) {
                              return Center(child: Text('Error: ${snapshot.error}'));
                            } else {
                              return snapshot.data ?? const Center(child: Text('No activity'));
                            }
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              
              // Middle row - personal task kanban [largest section for task management]
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.35,
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
                          child: FutureBuilder<Widget>(
                            future: _kanbanContent,
                            builder: (context, snapshot) {
                              if (snapshot.connectionState == ConnectionState.waiting) {
                                return const Center(child: CircularProgressIndicator());
                              } else if (snapshot.hasError) {
                                return Center(child: Text('Error: ${snapshot.error}'));
                              } else {
                                return snapshot.data ?? const Center(child: Text('No tasks'));
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              
              // Bottom row - deadline timeline [shows upcoming due dates]
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.22,
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
                          child: FutureBuilder<Widget>(
                            future: _deadlinesContent,
                            builder: (context, snapshot) {
                              if (snapshot.connectionState == ConnectionState.waiting) {
                                return const Center(child: CircularProgressIndicator());
                              } else if (snapshot.hasError) {
                                return Center(child: Text('Error: ${snapshot.error}'));
                              } else {
                                return snapshot.data ?? const Center(child: Text('No deadlines'));
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
