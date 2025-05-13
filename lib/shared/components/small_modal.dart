import 'package:flutter/material.dart';

// lightweight popup dialog for forms and confirmations
// made it to be the reusable component for the popups on the projects screen mainly for join code, links etc
class SmallModal extends StatelessWidget {
  final String title;
  final Widget content;
  final VoidCallback? onClose;
  final bool showCloseButton;
  final bool showActionButtons;  // controls bottom buttons visibility - not alwsys needed 
  
  const SmallModal({
    Key? key,
    required this.title,
    required this.content,
    this.onClose,
    this.showCloseButton = true,
    this.showActionButtons = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Dialog(
      // rounded corners for nice look
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Container(
        width: 400, // fixed width dialog for consistency
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // header with title and optional close button
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (showCloseButton)
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: onClose ?? () => Navigator.of(context).pop(),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            
            // main content area [passed in by caller]
            content,
            
            // optional action buttons at bottom
            if (showActionButtons) ...[
              const SizedBox(height: 20),
              
              // standard cancel/ok buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Cancel'),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () {
                      // default behaviour just closes modal
                      Navigator.of(context).pop();
                    },
                    child: const Text('OK'),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// helper function to easily show modal from anywhere in app
// [wraps showDialog with our custom modal]
void showSmallModal({
  required BuildContext context,
  required String title,
  required Widget content,
  VoidCallback? onClose,
  bool showCloseButton = true,
  bool showActionButtons = true,
}) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return SmallModal(
        title: title,
        content: content,
        onClose: onClose,
        showCloseButton: showCloseButton,
        showActionButtons: showActionButtons,
      );
    },
  );
}

// example widget showing modal usage
// [can be used for testing or documentation]
class SmallModalExample extends StatelessWidget {
  const SmallModalExample({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () {
        showSmallModal(
          context: context,
          title: 'Basic Modal',
          content: const Text('This is a simple modal content!'),
        );
      },
      child: const Text('Show Modal'),
    );
  }
}