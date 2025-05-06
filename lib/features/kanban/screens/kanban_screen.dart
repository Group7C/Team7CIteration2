// Kanban board screen with project and user views
import 'package:flutter/material.dart';
import '../board/containers/user_kanban.dart';
import '../board/containers/project_kanban.dart';
import '../../tasks/index.dart'; // Import tasks module including the AddTaskModal

class KanbanScreen extends StatefulWidget {
  const KanbanScreen({Key? key}) : super(key: key);

  @override
  State<KanbanScreen> createState() => _KanbanScreenState();
}

class _KanbanScreenState extends State<KanbanScreen> {
  bool _showUserView = true; // Toggle between user and project view
  String _selectedProjectId = 'project1'; // Default selected project
  
  // List of projects for dropdown selection
  final List<Map<String, String>> _projects = [
    {'id': 'project1', 'name': 'Website Redesign'},
    {'id': 'project2', 'name': 'Market Analysis'},
    {'id': 'project3', 'name': 'QA Testing'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_showUserView ? 'My Tasks' : 'Project Tasks'),
        actions: [
          // Toggle between user and project view
          IconButton(
            icon: Icon(_showUserView ? Icons.people : Icons.person),
            tooltip: _showUserView ? 'Switch to Project View' : 'Switch to My Tasks',
            onPressed: () {
              setState(() {
                _showUserView = !_showUserView;
              });
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Controls section
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                // Show project selector only in project view
                if (!_showUserView)
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      decoration: const InputDecoration(
                        labelText: 'Select Project',
                        border: OutlineInputBorder(),
                      ),
                      value: _selectedProjectId,
                      items: _projects
                          .map((project) => DropdownMenuItem(
                                value: project['id'],
                                child: Text(project['name']!),
                              ))
                          .toList(),
                      onChanged: (String? newValue) {
                        if (newValue != null) {
                          setState(() {
                            _selectedProjectId = newValue;
                          });
                        }
                      },
                    ),
                  ),
                
                // Empty space in user view
                if (_showUserView)
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        'Showing all your tasks across projects',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ),
                  ),
                
                const SizedBox(width: 16),
                
                // Add task button
                ElevatedButton.icon(
                  icon: const Icon(Icons.add),
                  label: const Text('Add Task'),
                  onPressed: () {
                    // Get project name from project ID
                    final projectName = _projects.firstWhere(
                      (p) => p['id'] == _selectedProjectId, 
                      orElse: () => {'id': _selectedProjectId, 'name': 'Unknown Project'}
                    )['name']!;
                    
                    // Show the add task modal
                    showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                      ),
                      builder: (ctx) {
                        return AddTaskModal(
                          projectName: projectName,
                          projectId: _selectedProjectId,
                          // You would dynamically fetch project members in a real app
                          projectMembers: ['You', 'Member 1', 'Member 2'],
                          onTaskAdded: (task) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Task added successfully!'),
                                backgroundColor: Colors.green,
                              ),
                            );
                          },
                        );
                      },
                    );
                  },
                ),
              ],
            ),
          ),
          
          // Kanban board container - switch between user and project view
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: _showUserView
                  ? const UserKanban(userId: 'user1') // Fixed to user1 for demo
                  : ProjectKanban(projectId: _selectedProjectId),
            ),
          ),
        ],
      ),
    );
  }
}