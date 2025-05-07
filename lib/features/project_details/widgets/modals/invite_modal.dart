import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../../features/common/widgets/action_button.dart';
import '../../../../../features/common/modals/small_modal.dart';

class InviteModal {
  /// Shows a modal dialog for inviting team members with a join code
  static void show({
    required BuildContext context,
    required String projectName,
    required String joinCode,
  }) {
    SmallModal.showJoinCode(
      context: context,
      projectName: projectName,
      joinCode: joinCode,
    );
  }
  
  /// Shows a custom invite modal if needed in the future
  static void showCustom({
    required BuildContext context,
    required String projectName,
    required String joinCode,
  }) {
    SmallModal.show(
      context: context,
      title: 'Invite Team Members',
      subtitle: 'Share this code to invite others to join "$projectName"',
      content: [
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey.shade800,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                joinCode,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        Center(
          child: ActionButton(
            label: 'Copy Code',
            icon: Icons.copy,
            onPressed: () {
              Clipboard.setData(ClipboardData(text: joinCode));
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Join code copied to clipboard'),
                  duration: Duration(seconds: 2),
                ),
              );
            },
            backgroundColor: const Color(0xFF5865F2), // Discord color
            scale: 0.9,
          ),
        ),
      ],
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text(
            'Close',
            style: TextStyle(color: Colors.white70),
          ),
        ),
      ],
    );
  }
}
