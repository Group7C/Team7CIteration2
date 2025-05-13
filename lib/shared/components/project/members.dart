import 'package:flutter/material.dart';
import '../container_template.dart';
import '../member_avatar.dart';
import '../action_button.dart';
import '../../../projects/project_model.dart';
import '../small_modal.dart';
import 'package:flutter/services.dart';

// displays and manages project members
// [shows avatars and provides invitation functionality]
class MembersComponent extends StatefulWidget {
  final Project? project;
  
  const MembersComponent({super.key, this.project});

  @override
  State<MembersComponent> createState() => _MembersComponentState();
}

class _MembersComponentState extends State<MembersComponent> {
  // extracts user initials from username
  // [used for avatar display]
  String _getInitials(String username) {
    if (username.isEmpty) return '?';
    // if username has spaces, use first letter of each word
    if (username.contains(' ')) {
      return username.split(' ').map((word) => word.isNotEmpty ? word[0] : '').join().toUpperCase();
    }
    // otherwise, use first two letters of username
    return username.length >= 2 ? username.substring(0, 2).toUpperCase() : username[0].toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    // create member data for avatar display
    final List<Map<String, dynamic>> groupMembers = [];
    
    if (widget.project != null && widget.project!.members.isNotEmpty) {
      widget.project!.members.forEach((username, role) {
        groupMembers.add({
          'initials': _getInitials(username),
          'username': username,
          'role': role,
        });
      });
    }
    
    return ContainerTemplate(
      title: 'Members',
      height: 250,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // members heading with count
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Group Members (${groupMembers.length})',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              if (groupMembers.isEmpty)
                // empty state message
                const Center(
                  child: Text('No members yet'),
                )
              else
                // member avatars display
                Center(
                  child: GroupAvatars(
                    members: groupMembers,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 24),
          // invite button to share join code
          ActionButton(
            label: 'Invite',
            icon: Icons.person_add,
              onPressed: () {
              final currentProject = widget.project;
              if (currentProject == null) return;
              
              // show join code in popup for sharing
              showSmallModal(
                context: context,
                title: 'Invite to Project',
                content: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (currentProject.joinCode != null)
                      ...[   
                        Text(
                          'Share this join code with others:',
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
                                child: Text(
                                  currentProject.joinCode,
                                  style: theme.textTheme.titleLarge?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: theme.colorScheme.primary,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            // copy button for easy sharing
                            IconButton(
                              icon: const Icon(Icons.copy),
                              onPressed: () {
                                Clipboard.setData(ClipboardData(text: currentProject.joinCode));
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Join code copied!')),
                                );
                              },
                              tooltip: 'Copy join code',
                            ),
                          ],
                        ),
                      ]
                    else
                      const Text('No join code available for this project.'),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}