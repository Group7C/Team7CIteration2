import 'package:flutter/material.dart';

class InfoSectionContainer extends StatelessWidget {
  final IconData icon;
  final String title;
  final List<Widget> children;
  final Color? iconColor;

  const InfoSectionContainer({
    Key? key,
    required this.icon,
    required this.title,
    required this.children,
    this.iconColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title with icon
          Row(
            children: [
              Icon(
                icon,
                size: 18,
                color: iconColor ?? Colors.white,
              ),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 15,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          // Content
          ...children,
        ],
      ),
    );
  }
}
