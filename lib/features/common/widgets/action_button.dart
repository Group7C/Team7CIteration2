import 'package:flutter/material.dart';

// Reusable action button with icon and text [used across app for consistent UI]
class ActionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onPressed;
  final Color? backgroundColor; // Button fill colour
  final Color? textColor; // Text and icon colour
  final double scale; // Size multiplier for button
  final EdgeInsetsGeometry? margin; // External spacing

  const ActionButton({
    Key? key,
    required this.label,
    required this.icon,
    required this.onPressed,
    this.backgroundColor,
    this.textColor,
    this.scale = 0.8, // Slightly smaller than primary buttons by default
    this.margin,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Use the bright blue color from Add Task button as default
    final bgColor = backgroundColor ?? const Color(0xFF1E88E5); // Bright blue color
    final txtColor = textColor ?? Colors.white;
    
    // Base sizes - scaled by scale parameter for visual consistency
    final baseHeight = 48.0;
    final basePadding = 20.0;
    final baseIconSize = 22.0;
    final baseFontSize = 16.0;
    
    return Container(
      height: baseHeight * scale,
      margin: margin,
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: Icon(
          icon,
          color: txtColor,
          size: baseIconSize * scale,
        ),
        label: Text(
          label,
          style: TextStyle(
            color: txtColor,
            fontWeight: FontWeight.w600,
            fontSize: baseFontSize * scale,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: bgColor,
          foregroundColor: txtColor,
          elevation: 2,
          padding: EdgeInsets.symmetric(
            horizontal: basePadding * scale,
            vertical: 8 * scale,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20 * scale),
          ),
        ),
      ),
    );
  }
}
