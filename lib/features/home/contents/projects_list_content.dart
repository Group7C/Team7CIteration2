import 'package:flutter/material.dart';

class ProjectsListContent extends StatelessWidget {
  final List<ProjectItem> projects;
  final Function(ProjectItem)? onProjectTap;

  const ProjectsListContent({
    Key? key,
    required this.projects,
    this.onProjectTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: projects.length,
      itemBuilder: (context, index) {
        return _buildProjectItem(context, projects[index]);
      },
    );
  }

  // Creates individual project card with status indicator
  Widget _buildProjectItem(BuildContext context, ProjectItem project) {
    return Card(
      child: ListTile(
        leading: Container(
          width: 4,
          height: 24,
          decoration: BoxDecoration(
            color: _getProgressColor(project.progress),
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        title: Text(project.name),
        subtitle: Text("${project.memberCount} members"),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: _getProgressColor(project.progress).withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            "${project.progress}%",
            style: TextStyle(
              color: _getProgressColor(project.progress),
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        onTap: () {
          if (onProjectTap != null) {
            onProjectTap!(project);
          }
        },
      ),
    );
  }

  // Determines colour based on progress [green=good, red=behind]
  Color _getProgressColor(int progress) {
    if (progress >= 75) return Colors.green;
    if (progress >= 40) return Colors.blue;
    if (progress >= 10) return Colors.amber;
    return Colors.red;
  }
}

// Project data model [represents individual project summary]
class ProjectItem {
  final String name;
  final int memberCount;
  final int progress;
  final String? id;

  ProjectItem({
    required this.name,
    required this.memberCount,
    required this.progress,
    this.id,
  });
}
