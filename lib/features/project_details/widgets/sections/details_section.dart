import 'package:flutter/material.dart';
import '../../models/project_details_view_model.dart';
import '../../utils/date_formatter.dart';
import '../../../../features/common/widgets/section_card.dart';
import '../../../../features/common/widgets/action_button.dart';

class DetailsSection extends StatelessWidget {
  final ProjectDetailsViewModel viewModel;
  final Function(String, String) onLinkPress;
  
  const DetailsSection({
    Key? key,
    required this.viewModel,
    required this.onLinkPress,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (!viewModel.hasProject) return const SizedBox();
    
    return SectionCard(
      title: 'Project Details',
      height: 220,
      content: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Description',
              style: TextStyle(color: Colors.white70, fontSize: 14),
            ),
            const SizedBox(height: 8),
            Text(
              viewModel.projectName,
              style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 16),
            if (viewModel.deadline != null) ...[
              Row(
                children: [
                  const Icon(
                    Icons.calendar_today,
                    color: Colors.blue,
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'Deadline:',
                    style: TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    DateFormatter.formatDate(viewModel.deadline!),
                    style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w500),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                '${DateFormatter.getDaysRemaining(viewModel.deadline!)} days remaining',
                style: const TextStyle(color: Colors.white70, fontSize: 14),
              ),
            ],
            const Spacer(),
            // Google Drive and Discord buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                SizedBox(
                  width: 150, // Fixed width for both buttons
                  child: ActionButton(
                    label: 'Google Drive',
                    icon: Icons.cloud,
                    onPressed: () {
                      onLinkPress('Google Drive Link', viewModel.googleDriveLink ?? 'No link available');
                    },
                    backgroundColor: Colors.blue.shade700,
                    scale: 0.9,
                  ),
                ),
                SizedBox(
                  width: 150, // Fixed width for both buttons
                  child: ActionButton(
                    label: 'Discord',
                    icon: Icons.chat,
                    onPressed: () {
                      onLinkPress('Discord Link', viewModel.discordLink ?? 'No link available');
                    },
                    backgroundColor: const Color(0xFF5865F2), // Discord purple
                    scale: 0.9,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
