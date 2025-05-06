import 'package:flutter/material.dart';
import '../../../shared/widgets/action_button.dart';

class ProjectDetailsContainer extends StatelessWidget {
  final String title;
  final IconData icon;
  final Widget content;
  final Color? iconColor;
  final String? actionLabel;
  final IconData? actionIcon;
  final VoidCallback? onAction;

  const ProjectDetailsContainer({
    Key? key,
    required this.title,
    required this.icon,
    required this.content,
    this.iconColor,
    this.actionLabel,
    this.actionIcon,
    this.onAction,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      // Make the card take full width of its parent
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      icon,
                      color: iconColor ?? Theme.of(context).primaryColor,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                if (actionLabel != null && actionIcon != null && onAction != null)
                  ActionButton(
                    label: actionLabel!,
                    icon: actionIcon!,
                    onPressed: onAction!,
                    scale: 0.8, // Sized for header
                  ),
              ],
            ),
            const Divider(),
            content,
          ],
        ),
      ),
    );
  }
}
