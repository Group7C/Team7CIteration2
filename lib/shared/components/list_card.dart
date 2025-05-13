import 'package:flutter/material.dart';

// reusable list item card for consistent items in lists
// [supports leading icon, title, subtitle, and trailing icon]
class ListCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData? leadingIcon;
  final IconData? trailingIcon;
  final VoidCallback? onTap;

  const ListCard({
    super.key,
    required this.title,
    required this.subtitle,
    this.leadingIcon,
    this.trailingIcon,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      elevation: 1,
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: ListTile(
        // optional leading icon in circle
        leading: leadingIcon != null
            ? CircleAvatar(
                backgroundColor: colorScheme.primaryContainer,
                child: Icon(
                  leadingIcon,
                  color: colorScheme.onPrimaryContainer,
                ),
              )
            : null,
        // main item title
        title: Text(
          title,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        // secondary descriptive text
        subtitle: Text(
          subtitle,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
        ),
        // optional trailing icon (often used for navigation)
        trailing: trailingIcon != null
            ? Icon(
                trailingIcon,
                color: colorScheme.onSurfaceVariant,
              )
            : null,
        // handle taps or provide default feedback
        onTap: onTap ?? () {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('$title tapped')),
          );
        },
      ),
    );
  }
}