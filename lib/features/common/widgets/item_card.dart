import 'package:flutter/material.dart';
import '../utils/theme_utils.dart';

class ItemCard extends StatelessWidget {
  final String title;
  final String? subtitle;
  final String? description;
  final DateTime? date;
  final Widget? leadingIcon;
  final List<Widget>? tags;
  final double? progress;
  final VoidCallback? onTap;
  final Color cardColor;
  final Color textColor;
  final bool showBorder;
  final Color borderColor;
  final Widget? trailingWidget;

  const ItemCard({
    Key? key,
    required this.title,
    this.subtitle,
    this.description,
    this.date,
    this.leadingIcon,
    this.tags,
    this.progress,
    this.onTap,
    this.cardColor = const Color(0xFF2A2E32),
    this.textColor = Colors.white,
    this.showBorder = false,
    this.borderColor = Colors.blue,
    this.trailingWidget,
  }) : super(key: key);
  
  // Factory constructor that uses theme colors
  factory ItemCard.themed({
    Key? key,
    required String title,
    String? subtitle,
    String? description,
    DateTime? date,
    Widget? leadingIcon,
    List<Widget>? tags,
    double? progress,
    VoidCallback? onTap,
    bool showBorder = false,
    Widget? trailingWidget,
    required BuildContext context,
  }) {
    return ItemCard(
      key: key,
      title: title,
      subtitle: subtitle,
      description: description,
      date: date,
      leadingIcon: leadingIcon,
      tags: tags,
      progress: progress,
      onTap: onTap,
      cardColor: ThemeUtils.getCardColor(context),
      textColor: ThemeUtils.getTextColor(context),
      showBorder: showBorder,
      borderColor: ThemeUtils.getPrimaryColor(context),
      trailingWidget: trailingWidget,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      color: cardColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: showBorder 
            ? BorderSide(color: borderColor, width: 1) 
            : BorderSide.none,
      ),
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header row with title, status indicators
              Row(
                children: [
                  if (leadingIcon != null) ...[
                    leadingIcon!,
                    const SizedBox(width: 12),
                  ],
                  Expanded(
                    child: Text(
                      title,
                      style: TextStyle(
                        color: textColor,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (trailingWidget != null) trailingWidget!,
                ],
              ),
              
              // Subtitle if available
              if (subtitle != null) ...[
                const SizedBox(height: 4),
                Text(
                  subtitle!,
                  style: TextStyle(
                    color: textColor.withOpacity(0.7),
                    fontSize: 14,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
              
              // Description if available
              if (description != null) ...[
                const SizedBox(height: 8),
                Text(
                  description!,
                  style: TextStyle(
                    color: textColor.withOpacity(0.9),
                    fontSize: 14,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
              
              // Progress bar if available
              if (progress != null) ...[
                const SizedBox(height: 12),
                LinearProgressIndicator(
                  value: progress,
                  backgroundColor: Colors.grey.shade800,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    progress! < 0.3 
                        ? Colors.red 
                        : progress! < 0.7 
                            ? Colors.amber 
                            : Colors.green,
                  ),
                  minHeight: 5,
                  borderRadius: BorderRadius.circular(3),
                ),
              ],
              
              // Footer with tags and date
              if (tags != null || date != null) ...[
                const SizedBox(height: 12),
                Row(
                  children: [
                    if (tags != null && tags!.isNotEmpty) ...[
                      Expanded(
                        child: Wrap(
                          spacing: 8,
                          runSpacing: 4,
                          children: tags!,
                        ),
                      ),
                    ],
                    if (date != null) ...[
                      Text(
                        _formatDate(date!),
                        style: TextStyle(
                          color: textColor.withOpacity(0.6),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
  
  // Helper method to format date
  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = date.difference(now).inDays;
    
    if (difference == 0) {
      return 'Today';
    } else if (difference == 1) {
      return 'Tomorrow';
    } else if (difference > 1 && difference < 7) {
      return '${difference.abs()} days';
    } else if (difference < 0 && difference > -7) {
      return '${difference.abs()} days ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}

// Tag widget for consistent tag styling
class ItemTag extends StatelessWidget {
  final String label;
  final Color color;

  const ItemTag({
    Key? key,
    required this.label,
    this.color = Colors.blue,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color.withOpacity(0.5), width: 1),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
