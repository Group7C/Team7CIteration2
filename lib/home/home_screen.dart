// lib/home/home_screen.dart
import 'package:flutter/material.dart';
import 'package:sevenc_iteration_two/home/components/meetings/meeting_page.dart';
import 'components/components.dart';
import 'components/compact/compact_components.dart';

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
                // Projects List - Compact Version
                Expanded(
                  child: CompactProjectList(),
                ),
                const SizedBox(width: 16),
                // Groups List - Compact Version
                Expanded(
                  child: CompactGroupsList(),
                ),
                const SizedBox(width: 16),
                // Activity Tracker - Compact Version
                Expanded(
                  child: CompactActivityTracker(),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // Middle row with Kanban
          Expanded(
            flex: 3,
            child: ConstrainedBox(
              constraints: const BoxConstraints(minHeight: 1500),
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
                        child: KanbanBoard(),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          // Bottom row with deadline manager
          Expanded(
            flex: 2,
            child: const DeadlineManager(),
          ),
        ],
      ),
    );
  }

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
    return const MeetingPage();
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
