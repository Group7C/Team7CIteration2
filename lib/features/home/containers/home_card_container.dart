import 'package:flutter/material.dart';

class HomeCardContainer extends StatelessWidget {
  final String title;
  final Widget content;
  final IconButton? actionButton;
  final TextButton? viewAllButton;
  final Color? titleColor;

  const HomeCardContainer({
    Key? key,
    required this.title,
    required this.content,
    this.actionButton,
    this.viewAllButton,
    this.titleColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: titleColor,
                  ),
                ),
                if (actionButton != null) actionButton!,
                if (viewAllButton != null) viewAllButton!,
              ],
            ),
            Expanded(
              child: content,
            ),
          ],
        ),
      ),
    );
  }
}
