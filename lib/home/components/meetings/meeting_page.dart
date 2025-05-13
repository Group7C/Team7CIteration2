import 'package:flutter/material.dart';

class MeetingPage extends StatefulWidget {
  const MeetingPage({super.key});

  @override
  State<MeetingPage> createState() => _MeetingPageState();
}

  class _MeetingPageState extends State<MeetingPage> {
  final TextEditingController meetingTypeController = TextEditingController();
  final TextEditingController meetingSubjectsController = TextEditingController();
  final TextEditingController meetingProgressController = TextEditingController();
  final TextEditingController meetingSummaryController = TextEditingController();
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  DateTime? startDate;
  DateTime? endDate;

  Future<void> pickStartDate() async {
    DateTime? selectedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (selectedDate != null) {
      setState(() {
        startDate = selectedDate;
      });
    }
  }

  Future<void> pickEndDate() async {
    DateTime? selectedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (selectedDate != null) {
      setState(() {
        endDate = selectedDate;
      });
    }
  }

  void clearForm() {
    setState(() {
      meetingTypeController.clear();
      meetingSubjectsController.clear();
      meetingProgressController.clear();
      meetingSummaryController.clear();
      startDate = null;
      endDate = null;
    });
  }

  void createMeeting() {
    if (formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: const Text(
                "Meeting created successfully!")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Form(
        key: formKey,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Left Column
            Expanded(
              flex: 1,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 16),
                  Text("Meeting Type",
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: colorScheme.primary,
                      )),
                  TextFormField(
                    controller: meetingTypeController,
                    maxLines: 3,
                    decoration: InputDecoration(
                      hintText: "Enter the meeting type",
                      hintStyle: TextStyle(
                          color: colorScheme.onSurface.withAlpha(153)),
                      filled: true,
                      fillColor: colorScheme.surface,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    style: TextStyle(color: colorScheme.onSurface),
                    validator: (value) =>
                    value!.isEmpty ? "Type cannot be empty" : null,
                  ),
                  const SizedBox(height: 16),
                  Text("Start Date",
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: colorScheme.primary,
                      )),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          startDate == null
                              ? "No date selected"
                              : "${startDate!.day}/${startDate!.month}/${startDate!.year}",
                          style: TextStyle(color: colorScheme.onSurface),
                        ),
                      ),
                      TextButton(
                        onPressed: pickStartDate,
                        child: Text("Pick Date",
                            style: TextStyle(color: colorScheme.primary)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text("End Date",
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: colorScheme.primary,
                      )),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          endDate == null
                              ? "No date selected"
                              : "${endDate!.day}/${endDate!.month}/${endDate!.year}",
                          style: TextStyle(color: colorScheme.onSurface),
                        ),
                      ),
                      TextButton(
                        onPressed: pickStartDate,
                        child: Text("Pick Date",
                            style: TextStyle(color: colorScheme.primary)),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(width: 32), // Spacing between columns

            // Right Column
            Expanded(
              flex: 1,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Meeting Subjects",
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: colorScheme.primary,
                      )),
                  TextFormField(
                    controller: meetingSubjectsController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      hintText: "Enter the meeting subjects",
                      hintStyle: TextStyle(
                          color: colorScheme.onSurface.withAlpha(153)),
                      filled: true,
                      fillColor: colorScheme.surface,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    style: TextStyle(color: colorScheme.onSurface),
                  ),
                  const SizedBox(height: 16),

                  Text("Meeting Progress",
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: colorScheme.primary,
                      )),
                  TextFormField(
                    controller: meetingProgressController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      hintText: "Enter the meeting progress",
                      hintStyle: TextStyle(
                          color: colorScheme.onSurface.withAlpha(153)),
                      filled: true,
                      fillColor: colorScheme.surface,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    style: TextStyle(color: colorScheme.onSurface),
                  ),
                  const SizedBox(height: 16),

                  Text("Meeting Summary",
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: colorScheme.primary,
                      )),
                  TextFormField(
                    controller: meetingSummaryController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      hintText: "Enter the meeting summary",
                      hintStyle: TextStyle(
                          color: colorScheme.onSurface.withAlpha(153)),
                      filled: true,
                      fillColor: colorScheme.surface,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    style: TextStyle(color: colorScheme.onSurface),
                  ),
                  const Spacer(),

                  // Action Buttons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      ElevatedButton(
                        onPressed: clearForm,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: colorScheme.error,
                          foregroundColor: colorScheme.onError,
                        ),
                        child: const Text("Clear"),
                      ),
                      const SizedBox(width: 16),
                      ElevatedButton(
                        onPressed: createMeeting,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: colorScheme.primaryContainer,
                          foregroundColor: colorScheme.onPrimaryContainer,
                        ),
                        child: const Text("Create"),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}