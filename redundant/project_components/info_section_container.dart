import 'package:flutter/material.dart';

class InfoSectionContainer extends StatelessWidget {
  final String title;
  final IconData icon;
  final List<Widget> children;
  final Color? iconColor;
  final String? actionLabel;
  final IconData? actionIcon;
  final VoidCallback? onAction;

  const InfoSectionContainer({
    Key? key,
    required this.title,
    required this.icon,
    required this.children,
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
                  TextButton.icon(
                    onPressed: onAction,
                    icon: Icon(
                      actionIcon,
                      size: 16,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    label: Text(
                      actionLabel!,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.primary,
                        fontSize: 13,
                      ),
                    ),
                  ),
              ],
            ),
            const Divider(),
            ...children,
          ],
        ),
      ),
    );
  }
}
