import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../../features/common/widgets/action_button.dart';
import '../../../../../features/common/modals/small_modal.dart';

class LinkSharingModal {
  /// Shows a modal dialog for sharing links
  static void show({
    required BuildContext context,
    required String title,
    required String link,
    required String linkType,
  }) {
    SmallModal.show(
      context: context,
      title: title,
      subtitle: 'Copy this $linkType link to share:',
      content: [
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          decoration: BoxDecoration(
            color: Colors.grey.shade800,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  link,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        Center(
          child: ActionButton(
            label: 'Copy Link',
            icon: Icons.copy,
            onPressed: () {
              // Copy link to clipboard
              Clipboard.setData(ClipboardData(text: link));
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('$linkType link copied to clipboard'),
                  duration: const Duration(seconds: 2),
                ),
              );
            },
            backgroundColor: linkType == 'Google Drive' ? Colors.blue.shade700 : const Color(0xFF5865F2),
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
