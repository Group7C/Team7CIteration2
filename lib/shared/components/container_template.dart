import 'package:flutter/material.dart';

// standard container layout for app sections
// used extensively on the home screen and projects screen
// [handles title, optional description, and content]
class ContainerTemplate extends StatelessWidget {
  final String title;
  final String? description;
  final Widget? child;
  final bool scrollableChild;
  final double? height;

  const ContainerTemplate({
    super.key,
    required this.title,
    this.description,
    this.child,
    this.scrollableChild = false,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      elevation: 1,
      child: Container(
        height: height,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // section title with bold styling
              Text(
                title,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              
              // subtle divider to separate title from content
              Container(
                height: 1,
                color: colorScheme.outlineVariant.withOpacity(0.5),
              ),
              const SizedBox(height: 12),
              
              // either description text or scrollable content
              if (description != null && !scrollableChild)
                Text(
                  description!,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                )
              else if (scrollableChild && child != null)
                // wrap in scroll view when content might overflow
                Expanded(
                  child: SingleChildScrollView(
                    child: child!,
                  ),
                ),
              
              // static content when not scrollable
              if (child != null && !scrollableChild) ...[
                const SizedBox(height: 16),
                child!,
              ],
            ],
          ),
        ),
      ),
    );
  }
}