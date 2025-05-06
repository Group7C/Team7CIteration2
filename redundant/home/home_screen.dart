// lib/home/home_screen.dart
import 'package:flutter/material.dart';
import 'components/components.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  String screenTitle = "Team 7C";

  Widget createHomeBody() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          // Top row with three equal columns
          Expanded(
            flex: 2,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Projects List
                Expanded(
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
                                "Projects",
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.add),
                                onPressed: () {},
                              ),
                            ],
                          ),
                          Expanded(
                            child: ListView.builder(
                              itemCount: 3,
                              itemBuilder: (context, index) {
                                return Card(
                                  child: ListTile(
                                    title: Text("Project ${index + 1}"),
                                    subtitle: const Text("5 members"),
                                    trailing: const Text("75%"),
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                // Groups List
                Expanded(
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
                                "Groups",
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.add),
                                onPressed: () {},
                              ),
                            ],
                          ),
                          Expanded(
                            child: ListView.builder(
                              itemCount: 3,
                              itemBuilder: (context, index) {
                                return Card(
                                  child: ListTile(
                                    title: Text("Group ${index + 1}"),
                                    subtitle: const Text("8 members"),
                                    trailing: Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.green[100],
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: const Text(
                                        "Active",
                                        style: TextStyle(color: Colors.green),
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                // Activity Tracker
                Expanded(
                  child: Card(
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
                                return ListTile(
                                  leading: CircleAvatar(
                                    backgroundColor: Colors.blue[100],
                                    child: const Icon(Icons.person),
                                  ),
                                  title:
                                      const Text("John Doe completed a task"),
                                  subtitle: Text("${index + 1} hours ago"),
                                );
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
          const SizedBox(height: 16),
          // Middle row with Kanban
// Middle row with Kanban
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
                    const Expanded(
                      child:
                          KanbanBoard(), // Replace the Row containing _buildKanbanColumn with this
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          // Bottom row with deadline manager
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
                          onPressed: () {},
                          icon: const Icon(Icons.calendar_today),
                          label: const Text("View Calendar"),
                        ),
                      ],
                    ),
                    Expanded(
                      child: ListView(
                        children: [
                          _buildDeadlineSection("Today"),
                          const SizedBox(height: 16),
                          _buildDeadlineSection("Tomorrow"),
                        ],
                      ),
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

  Widget _buildDeadlineSection(String day) {
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
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: List.generate(
            2,
            (index) => Container(
              width: 200,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Task ${index + 1}"),
                  const Text("Project Alpha"),
                  Row(
                    children: const [
                      Icon(Icons.access_time, size: 16),
                      SizedBox(width: 4),
                      Text("2:00 PM"),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  // Your existing methods remain exactly the same from here...
  Widget createProjectTimerCountdown() {
    return const Text("PLACEHOLDER");
  }

  Widget createTaskBody() {
    return Container(
      child: const Text("in here"),
    );
  }

  Widget createMessages() {
    return Container();
  }

  Widget createFiles() {
    return Container();
  }

  Widget createContributionReportBody() {
    return Container();
  }

  Widget createMeetings() {
    return Container();
  }

  Widget createAddTaskBody() {
    return const AddTaskForm();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 7,
      initialIndex: 1,
      child: Scaffold(
        backgroundColor: Colors.grey[850],
        appBar: AppBar(
          title: Text(screenTitle),
          bottom: const TabBar(
            tabs: <Widget>[
              Tab(text: "Home"),
              Tab(text: "Tasks"),
              Tab(text: "Add Tasks"),
              Tab(text: "Messages"),
              Tab(text: "Files"),
              Tab(text: "Meetings"),
              Tab(text: "Contribution Report")
            ],
          ),
        ),
        body: TabBarView(children: <Widget>[
          createHomeBody(),
          createTaskBody(),
          createAddTaskBody(),
          createMessages(),
          createFiles(),
          createMeetings(),
          createContributionReportBody()
        ]),
      ),
    );
  }
}
