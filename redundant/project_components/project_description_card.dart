import 'package:flutter/material.dart';
import 'info_section_container.dart';

class ProjectDescriptionCard extends StatelessWidget {
  final String description;
  
  const ProjectDescriptionCard({
    Key? key, 
    required this.description,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InfoSectionContainer(
      icon: Icons.description,
      title: 'Description',
      iconColor: Colors.purple,
      children: [
        const SizedBox(height: 8),
        Text(
          description,
          style: const TextStyle(
            fontSize: 14,
            height: 1.5,
          ),
        ),
      ],
    );
  }
}
