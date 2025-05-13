import 'package:flutter/material.dart';

// reusable button component with primary/secondary styling
// used extensively on the proejcts screen components
// [supports both icon and text variants]
class ActionButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool isPrimary;

  const ActionButton({
    super.key,
    required this.label,
    this.onPressed,
    this.icon,
    this.isPrimary = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // primary variant uses filled style [solid background]
    if (isPrimary) {
      return FilledButton.icon(
        onPressed: onPressed ?? () {
          // default feedback if no handler provided
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('$label pressed')),
          );
        },
        // only show icon if provided, otherwise empty space
        icon: icon != null ? Icon(icon) : const SizedBox.shrink(),
        label: Text(
          label,
          overflow: TextOverflow.ellipsis,
        ),
        style: FilledButton.styleFrom(
          backgroundColor: colorScheme.primary,
          foregroundColor: colorScheme.onPrimary,
        ),
      );
    } else {
      // secondary variant uses outlined style [transparent with border]
      return OutlinedButton.icon(
        onPressed: onPressed ?? () {
          // default feedback if no handler provided
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('$label pressed')),
          );
        },
        // only show icon if provided, otherwise empty space
        icon: icon != null ? Icon(icon) : const SizedBox.shrink(),
        label: Text(
          label,
          overflow: TextOverflow.ellipsis,
        ),
        style: OutlinedButton.styleFrom(
          side: BorderSide(color: colorScheme.outline),
          foregroundColor: colorScheme.primary,
        ),
      );
    }
  }
}