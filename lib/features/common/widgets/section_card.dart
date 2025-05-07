import 'package:flutter/material.dart';

class SectionCard extends StatelessWidget {
  final String title;
  final Widget? content;
  final double height;
  final String? emptyMessage;
  final IconData? emptyIcon;
  final Widget? actionButton;

  const SectionCard({
    Key? key,
    required this.title,
    this.content,
    this.height = 150,
    this.emptyMessage,
    this.emptyIcon,
    this.actionButton,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurface,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          height: height,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(8),
            // Border removed per client request
          ),
          child: content ?? _buildEmptyState(context),
        ),
      ],
    );
  }

  Widget? _buildEmptyState(BuildContext context) {
    if (emptyMessage == null && emptyIcon == null) {
      return null;
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (emptyIcon != null)
            Icon(
              emptyIcon,
              color: Theme.of(context).colorScheme.primary,
              size: 50,
            ),
          if (emptyIcon != null && emptyMessage != null)
            const SizedBox(height: 8),
          if (emptyMessage != null)
            Text(
              emptyMessage!,
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
              ),
            ),
          if (actionButton != null) 
            Padding(
              padding: const EdgeInsets.only(top: 16),
              child: actionButton,
            ),
        ],
      ),
    );
  }
}
