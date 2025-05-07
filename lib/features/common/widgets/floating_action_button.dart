import 'package:flutter/material.dart';

/// A floating action button styled to match the ActionButton component
/// for consistent UI across the application
class StyledFloatingActionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onPressed;
  final Color? backgroundColor;
  final Color? textColor;
  
  const StyledFloatingActionButton({
    Key? key,
    required this.label,
    required this.icon,
    required this.onPressed,
    this.backgroundColor,
    this.textColor,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    final bgColor = backgroundColor ?? const Color(0xFF1E88E5); // Same default as ActionButton
    final txtColor = textColor ?? Colors.white;
    
    return FloatingActionButton.extended(
      onPressed: onPressed,
      backgroundColor: bgColor,
      foregroundColor: txtColor,
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      icon: Icon(
        icon,
        size: 24,
      ),
      label: Text(
        label,
        style: const TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 16,
        ),
      ),
      extendedPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
    );
  }
}
