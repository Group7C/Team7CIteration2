import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../container_template.dart';
import '../../../usser/usserObject.dart';

class DetailsComponent extends StatelessWidget {
  const DetailsComponent({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final user = Provider.of<Usser>(context);
    
    // Get first letter of email for avatar - gone with this because we dont have
    // user first and last names as part of the registration, so best i  could think of
    String avatarLetter = user.email.isNotEmpty ? user.email[0].toUpperCase() : 'U';
    
    return ContainerTemplate(
      title: 'Details',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                backgroundColor: colorScheme.primaryContainer,
                radius: 24,
                child: Text(
                  avatarLetter,
                  style: TextStyle(
                    color: colorScheme.onPrimaryContainer,
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Welcome back...',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      user.email,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Divider(color: colorScheme.outlineVariant),
          const SizedBox(height: 16),
          Row(
            children: [
              Icon(
                Icons.access_time,
                color: colorScheme.primary,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                DateFormat('h:mm a').format(DateTime.now()),
                style: theme.textTheme.bodyLarge,
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(
                Icons.calendar_today,
                color: colorScheme.primary,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                DateFormat('MMMM d, yyyy').format(DateTime.now()),
                style: theme.textTheme.bodyLarge,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
