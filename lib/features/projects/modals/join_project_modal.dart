import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../../usser/usserObject.dart';

class JoinProjectModal extends StatefulWidget {
  const JoinProjectModal({Key? key}) : super(key: key);

  @override
  State<JoinProjectModal> createState() => _JoinProjectModalState();
}

class _JoinProjectModalState extends State<JoinProjectModal> {
  final TextEditingController joinCodeController = TextEditingController();
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  bool isLoading = false;
  String? errorMessage;

  @override
  void dispose() {
    joinCodeController.dispose();
    super.dispose();
  }

  Future<void> joinProject() async {
    if (formKey.currentState!.validate()) {
      setState(() {
        isLoading = true;
        errorMessage = null;
      });

      try {
        final usser = context.read<Usser>();
        final joinCode = joinCodeController.text.trim();

        // First, check if project exists with this join code
        final response = await http.post(
          Uri.parse('http://127.0.0.1:5000/join/project'),
          headers: {'Content-Type': 'application/json'},
          body: json.encode({
            'user_id': usser.usserID,
            'join_code': joinCode,
          }),
        );

        if (response.statusCode == 200) {
          final responseData = json.decode(response.body);
          
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Successfully joined project!'),
              backgroundColor: Colors.green,
            ),
          );
          
          // Return the project data to navigate to its details
          Navigator.of(context).pop(responseData['project_id']);
        } else {
          final errorData = json.decode(response.body);
          setState(() {
            errorMessage = errorData['error'] ?? 'Failed to join project';
          });
        }
      } catch (e) {
        setState(() {
          errorMessage = 'Error: ${e.toString()}';
        });
      } finally {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.background,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
      ),
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Join Project',
                style: theme.textTheme.headlineSmall,
              ),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Text(
            'Enter the join code to join a project:',
            style: theme.textTheme.titleMedium,
          ),
          const SizedBox(height: 16),
          Form(
            key: formKey,
            child: TextFormField(
              controller: joinCodeController,
              textCapitalization: TextCapitalization.characters,
              decoration: InputDecoration(
                hintText: 'Enter join code',
                filled: true,
                fillColor: theme.colorScheme.surface,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                prefixIcon: const Icon(Icons.key),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter a join code';
                }
                if (value.trim().length < 6) {
                  return 'Join code must be at least 6 characters';
                }
                return null;
              },
            ),
          ),
          if (errorMessage != null) ...[
            const SizedBox(height: 16),
            Text(
              errorMessage!,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.error,
              ),
            ),
          ],
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cancel'),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton(
                  onPressed: isLoading ? null : joinProject,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.colorScheme.primary,
                    foregroundColor: theme.colorScheme.onPrimary,
                  ),
                  child: isLoading
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                        ),
                      )
                    : const Text('Join'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
