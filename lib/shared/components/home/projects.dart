import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../container_template.dart';
import '../list_card.dart';
import '../../../providers/projects_provider.dart';
import '../../../projects/project_model.dart';

class ProjectsComponent extends StatelessWidget {
  const ProjectsComponent({super.key});

  @override
  Widget build(BuildContext context) {
    final projects = Provider.of<ProjectsProvider>(context).projects;
    
    return ContainerTemplate(
      title: 'My Projects',
      scrollableChild: true,
      height: 250,
      child: projects.isEmpty
          ? const Center(
              child: Text(
                'No projects yet',
                style: TextStyle(fontSize: 16),
              ),
            )
          : Column(
              children: projects.map((project) => ListCard(
                title: project.projectName,
                subtitle: 'Deadline: ${project.deadline.toString().split(' ')[0]} • Join Code: ${project.joinCode}',
                leadingIcon: Icons.folder,
                trailingIcon: Icons.arrow_forward_ios,
                onTap: () {
                  // Navigate to project details or handle tap
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Selected project: ${project.projectName}')),
                  );
                },
              )).toList(),
            ),
    );
  }
}
