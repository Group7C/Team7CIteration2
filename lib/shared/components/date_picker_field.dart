import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

// custom date input field with calendar picker
// [used for deadlines and scheduling]
class DatePickerField extends StatefulWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final Function(DateTime) onDateSelected;

  const DatePickerField({
    Key? key,
    required this.controller,
    required this.focusNode,
    required this.onDateSelected,
  }) : super(key: key);

  @override
  State<DatePickerField> createState() => _DatePickerFieldState();
}

class _DatePickerFieldState extends State<DatePickerField> {
  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.controller,
      focusNode: widget.focusNode,
      readOnly: true, // prevents keyboard from appearing
      decoration: InputDecoration(
        hintText: "Pick Date",
        filled: true,
        fillColor: Theme.of(context).colorScheme.surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        // calendar icon button to open date picker
        suffixIcon: IconButton(
          icon: const Icon(Icons.calendar_today),
          onPressed: _pickEndDate,
        ),
      ),
      // validation to ensure date is selected
      validator: (value) =>
          value == null || value.isEmpty ? "Please select a date" : null,
      // opens picker when field tapped
      onTap: () => _pickEndDate(),
      onFieldSubmitted: (_) {
        FocusScope.of(context).nextFocus();
      },
    );
  }

  // shows date picker dialog and updates field when date chosen
  void _pickEndDate() async {
    DateTime? selectedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(), // can't select dates in past
      lastDate: DateTime.now().add(const Duration(days: 365)), // limit to one year ahead
    );

    if (selectedDate != null) {
      // call parent callback with selected date
      widget.onDateSelected(selectedDate);
      // format date as yyyy-mm-dd for display
      widget.controller.text = DateFormat('yyyy-MM-dd').format(selectedDate);
    }
  }
}