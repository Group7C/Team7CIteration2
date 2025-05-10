import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

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
      readOnly: true,
      decoration: InputDecoration(
        hintText: "Pick Date",
        filled: true,
        fillColor: Theme.of(context).colorScheme.surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        suffixIcon: IconButton(
          icon: const Icon(Icons.calendar_today),
          onPressed: _pickEndDate,
        ),
      ),
      validator: (value) =>
          value == null || value.isEmpty ? "Please select a date" : null,
      onTap: () => _pickEndDate(),
      onFieldSubmitted: (_) {
        FocusScope.of(context).nextFocus();
      },
    );
  }

  void _pickEndDate() async {
    DateTime? selectedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (selectedDate != null) {
      widget.onDateSelected(selectedDate);
      widget.controller.text = DateFormat('yyyy-MM-dd').format(selectedDate);
    }
  }
}