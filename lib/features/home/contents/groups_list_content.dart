import 'package:flutter/material.dart';

class GroupsListContent extends StatelessWidget {
  final List<GroupItem> groups;
  final Function(GroupItem)? onGroupTap;

  const GroupsListContent({
    Key? key,
    required this.groups,
    this.onGroupTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (groups.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.group_outlined,
              size: 36,
              color: Theme.of(context).colorScheme.primary.withOpacity(0.5),
            ),
            const SizedBox(height: 8),
            Text(
              "No collaboration groups yet",
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
              ),
            ),
          ],
        ),
      );
    }
    
    return ListView.builder(
      itemCount: groups.length,
      itemBuilder: (context, index) {
        return _buildGroupItem(context, groups[index]);
      },
    );
  }

  Widget _buildGroupItem(BuildContext context, GroupItem group) {
    final isActive = group.status == "Active";
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 0),
      child: InkWell(
        onTap: () {
          if (onGroupTap != null) {
            onGroupTap!(group);
          }
        },
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      group.name,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: isActive ? Colors.green.withOpacity(0.2) : Colors.grey.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      group.status,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: isActive ? Colors.green : Colors.grey,
                      ),
                    ),
                  ),
                ],
              ),
              if (group.projectName != null && group.projectName!.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 4.0),
                  child: Text(
                    "Project: ${group.projectName}",
                    style: TextStyle(
                      fontSize: 12,
                      color: theme.colorScheme.onSurface.withOpacity(0.7),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              Padding(
                padding: const EdgeInsets.only(top: 4.0),
                child: Row(
                  children: [
                    Icon(
                      Icons.people_outline,
                      size: 14,
                      color: theme.colorScheme.primary,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      "${group.memberCount} members",
                      style: TextStyle(
                        fontSize: 12,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class GroupItem {
  final String name;
  final int memberCount;
  final String status;
  final String? id;
  final String? projectId;
  final String? projectName;
  final String? taskTitle;
  final Map<String, dynamic>? members;

  GroupItem({
    required this.name,
    required this.memberCount,
    required this.status,
    this.id,
    this.projectId,
    this.projectName,
    this.taskTitle,
    this.members,
  });
}