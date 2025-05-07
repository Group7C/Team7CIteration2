import 'package:flutter/material.dart';
import '../../models/project_details_view_model.dart';
import '../../../../features/common/widgets/section_card.dart';
import '../../../../features/common/widgets/action_button.dart';

class TeamMembersSection extends StatelessWidget {
  final ProjectDetailsViewModel viewModel;
  final VoidCallback onInvite;
  
  const TeamMembersSection({
    Key? key,
    required this.viewModel,
    required this.onInvite,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SectionCard(
      title: 'Team Members',
      height: 220,
      content: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Expanded(
              child: viewModel.members.isEmpty
                ? Center(
                    child: Text(
                      'No team members yet',
                      style: TextStyle(color: Colors.white70),
                    ),
                  )
                : SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        for (var member in viewModel.members)
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 10.0),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                CircleAvatar(
                                  radius: 28,
                                  backgroundColor: Colors.blue.shade700,
                                  child: Text(
                                    member.username?.substring(0, 1).toUpperCase() ?? 'S',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 20,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  member.username ?? 'Sample User',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
            ),
            const SizedBox(height: 16),
            ActionButton(
              label: 'Invite',
              icon: Icons.person_add,
              onPressed: onInvite,
              backgroundColor: const Color(0xFF5865F2), // Discord blue
              scale: 0.9,
              margin: const EdgeInsets.symmetric(horizontal: 8),
            ),
          ],
        ),
      ),
    );
  }
}
