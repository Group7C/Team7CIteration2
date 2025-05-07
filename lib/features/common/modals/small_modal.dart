import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../widgets/action_button.dart';

/// A reusable small modal dialog for displaying information and actions
class SmallModal extends StatelessWidget {
  final String title;
  final String? subtitle;
  final List<Widget> content;
  final List<Widget>? actions;
  final double width;
  final double? height;
  final Color backgroundColor;
  final EdgeInsetsGeometry padding;

  const SmallModal({
    Key? key,
    required this.title,
    this.subtitle,
    required this.content,
    this.actions,
    this.width = 400,
    this.height,
    this.backgroundColor = const Color(0xFF212529),
    this.padding = const EdgeInsets.all(24),
  }) : super(key: key);

  /// Show the small modal
  static Future<T?> show<T>({
    required BuildContext context,
    required String title,
    String? subtitle,
    required List<Widget> content,
    List<Widget>? actions,
    double width = 400,
    double? height,
    Color backgroundColor = const Color(0xFF212529),
    EdgeInsetsGeometry padding = const EdgeInsets.all(24),
    bool barrierDismissible = true,
  }) {
    return showDialog<T>(
      context: context,
      barrierDismissible: barrierDismissible,
      builder: (context) => SmallModal(
        title: title,
        subtitle: subtitle,
        content: content,
        actions: actions,
        width: width,
        height: height,
        backgroundColor: backgroundColor,
        padding: padding,
      ),
    );
  }

  /// Show a join code modal that allows copying the code
  static Future<void> showJoinCode({
    required BuildContext context,
    required String projectName,
    required String joinCode,
  }) {
    return show(
      context: context,
      title: 'Invite to $projectName',
      subtitle: 'Share this join code with your collaborators',
      content: [
        const SizedBox(height: 16),
        JoinCodeDisplay(joinCode: joinCode),
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
            backgroundColor: Colors.blue,
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

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        padding: padding,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title row with close button
            Row(
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.white70),
                  onPressed: () => Navigator.of(context).pop(),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  splashRadius: 20,
                ),
              ],
            ),
            
            // Subtitle if provided
            if (subtitle != null) ...[
              const SizedBox(height: 8),
              Text(
                subtitle!,
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                ),
              ),
            ],
            
            // Content
            ...content,
            
            // Actions section at bottom if provided
            if (actions != null && actions!.isNotEmpty) ...[
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: actions!,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// A widget to display a join code in a stylized way
class JoinCodeDisplay extends StatelessWidget {
  final String joinCode;
  
  const JoinCodeDisplay({
    Key? key, 
    required this.joinCode,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
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
              letterSpacing: 2.0,
            ),
          ),
        ],
      ),
    );
  }
}
