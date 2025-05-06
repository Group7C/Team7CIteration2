import 'package:flutter/material.dart';

class TeamMembersContent extends StatelessWidget {
  final int members;
  
  const TeamMembersContent({
    Key? key, 
    required this.members,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 12),
        Row(
          children: [
            const Icon(
              Icons.groups, 
              size: 16,
              color: Colors.indigo,
            ),
            const SizedBox(width: 8),
            Text(
              '$members team members',
              style: const TextStyle(
                fontSize: 14,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: List.generate(
            members > 5 ? 5 : members,
            (index) => Padding(
              padding: const EdgeInsets.only(right: 4.0),
              child: CircleAvatar(
                radius: 16,
                backgroundColor: Colors.primaries[index % Colors.primaries.length],
                child: Text(
                  String.fromCharCode(65 + index), // A, B, C, D, E
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ),
          ).toList(),
        ),
        if (members > 5)
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Text(
              '+ ${members - 5} more',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
          ),
      ],
    );
  }
}
