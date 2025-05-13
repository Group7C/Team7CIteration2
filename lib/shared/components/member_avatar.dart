import 'package:flutter/material.dart';

// displays user avatar with initials
// [used throughout app for consistent user representation]
class MemberAvatar extends StatelessWidget {
  final String initials;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final double radius;

  const MemberAvatar({
    super.key,
    required this.initials,
    this.backgroundColor,
    this.foregroundColor,
    this.radius = 24,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return CircleAvatar(
      radius: radius,
      backgroundColor: backgroundColor ?? colorScheme.primaryContainer,
      child: Text(
        initials.toUpperCase(),
        style: TextStyle(
          color: foregroundColor ?? colorScheme.onPrimaryContainer,
          fontWeight: FontWeight.bold,
          fontSize: radius * 0.6, // scale text based on avatar size
        ),
      ),
    );
  }
}

// went with a style that displays multiple overlapping member avatars
// can adjust the overlap etc
class GroupAvatars extends StatelessWidget {
  final List<Map<String, dynamic>> members;
  final double avatarRadius;
  final double overlapFactor;

  const GroupAvatars({
    super.key,
    required this.members,
    this.avatarRadius = 24,
    this.overlapFactor = 0.7, // 0.7 means 30% overlap between avatars
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    // calculate total width needed with overlap
    final double totalWidth = avatarRadius * 2 + (members.length - 1) * avatarRadius * 2 * overlapFactor;
    
    // alternate colours for visual variety
    final List<Color> containerColors = [
      colorScheme.primaryContainer,
      colorScheme.secondaryContainer,
      colorScheme.tertiaryContainer,
    ];
    
    final List<Color> onContainerColors = [
      colorScheme.onPrimaryContainer,
      colorScheme.onSecondaryContainer,
      colorScheme.onTertiaryContainer,
    ];

    return SizedBox(
      width: totalWidth,
      height: avatarRadius * 2,
      child: Stack(
        children: List.generate(members.length, (index) {
          final member = members[index];
          final colorIndex = index % containerColors.length;
          
          // position avatars with overlap
          return Positioned(
            left: index * avatarRadius * 2 * overlapFactor,
            child: MemberAvatar(
              initials: member['initials'] ?? '',
              backgroundColor: member['backgroundColor'] ?? containerColors[colorIndex],
              foregroundColor: member['foregroundColor'] ?? onContainerColors[colorIndex],
              radius: avatarRadius,
            ),
          );
        }),
      ),
    );
  }
}