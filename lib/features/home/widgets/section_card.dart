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
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          height: height,
          decoration: BoxDecoration(
            color: const Color(0xFF212529),
            borderRadius: BorderRadius.circular(8),
          ),
          child: content ?? _buildEmptyState(),
        ),
      ],
    );
  }

  Widget? _buildEmptyState() {
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
              color: Colors.blue.shade200,
              size: 50,
            ),
          if (emptyIcon != null && emptyMessage != null)
            const SizedBox(height: 8),
          if (emptyMessage != null)
            Text(
              emptyMessage!,
              style: const TextStyle(
                color: Colors.white70,
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
