import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../container_template.dart';
import '../action_button.dart';
import '../../../projects/project_model.dart';
import '../small_modal.dart';
import 'package:flutter/services.dart';

// displays basic project information and links 
// [shows deadline and integration links]
class ProjectDetailsComponent extends StatelessWidget {
  final Project? project;
  
  const ProjectDetailsComponent({super.key, this.project});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    // get project name for welcome message
    final projectName = project?.projectName ?? 'the project';
    final welcomeMessage = 'Welcome to $projectName.';
    
    // get project deadline
    final deadline = project?.deadline ?? DateTime.now();
    
    return ContainerTemplate(
      title: 'Details',
      height: 250,
      description: welcomeMessage,
      child: Column(
        children: [
          // deadline display with calendar icon
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Icon(
                Icons.calendar_today,
                color: colorScheme.primary,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Deadline: ',
                style: theme.textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                DateFormat('dd/MM/yyyy').format(deadline),
                style: theme.textTheme.bodyLarge,
              ),
            ],
          ),
          const SizedBox(height: 20),
          // integration link buttons
          Center(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // discord link button
                Flexible(
                  child: ActionButton(
                    label: 'Discord',
                    icon: Icons.chat,
                    onPressed: () {
                      final currentProject = project;
                      if (currentProject == null) return;
                      
                      // show modal with copyable discord link
                      showSmallModal(
                        context: context,
                        title: 'Discord Link',
                        content: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (currentProject.discordLink != null && currentProject.discordLink!.isNotEmpty)
                              ...[   
                                Text(
                                  'Discord server link:',
                                  style: theme.textTheme.bodyMedium,
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    Expanded(
                                      child: Container(
                                        padding: const EdgeInsets.all(12),
                                        decoration: BoxDecoration(
                                          color: theme.colorScheme.surfaceContainerHighest,
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: SelectableText(
                                          currentProject.discordLink!,
                                          style: theme.textTheme.titleLarge?.copyWith(
                                            fontWeight: FontWeight.bold,
                                            color: theme.colorScheme.primary,
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    IconButton(
                                      icon: const Icon(Icons.copy),
                                      onPressed: () {
                                        Clipboard.setData(ClipboardData(text: currentProject.discordLink!));
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          const SnackBar(content: Text('Discord link copied!')),
                                        );
                                      },
                                      tooltip: 'Copy link',
                                    ),
                                  ],
                                ),
                              ]
                            else
                              const Text('No Discord link has been set for this project.'),
                          ],
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(width: 8),
                // google drive link button
                Flexible(
                  child: ActionButton(
                    label: 'Google Drive',
                    icon: Icons.folder,
                    isPrimary: false,
                    onPressed: () {
                      final currentProject = project;
                      if (currentProject == null) return;
                      
                      // show modal with copyable drive link
                      showSmallModal(
                        context: context,
                        title: 'Google Drive Link',
                        content: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (currentProject.googleDriveLink != null && currentProject.googleDriveLink!.isNotEmpty)
                              ...[   
                                Text(
                                  'Google Drive folder link:',
                                  style: theme.textTheme.bodyMedium,
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    Expanded(
                                      child: Container(
                                        padding: const EdgeInsets.all(12),
                                        decoration: BoxDecoration(
                                          color: theme.colorScheme.surfaceContainerHighest,
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: SelectableText(
                                          currentProject.googleDriveLink!,
                                          style: theme.textTheme.titleLarge?.copyWith(
                                            fontWeight: FontWeight.bold,
                                            color: theme.colorScheme.primary,
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    IconButton(
                                      icon: const Icon(Icons.copy),
                                      onPressed: () {
                                        Clipboard.setData(ClipboardData(text: currentProject.googleDriveLink!));
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          const SnackBar(content: Text('Google Drive link copied!')),
                                        );
                                      },
                                      tooltip: 'Copy link',
                                    ),
                                  ],
                                ),
                              ]
                            else
                              const Text('No Google Drive link has been set for this project.'),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}