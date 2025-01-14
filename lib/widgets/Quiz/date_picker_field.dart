import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // For date formatting

class DateTimePickerField extends StatelessWidget {
  final String label;
  final DateTime initialDateTime;
  final ValueChanged<DateTime> onDateTimeChanged;

  const DateTimePickerField({
    super.key,
    required this.label,
    required this.initialDateTime,
    required this.onDateTimeChanged,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(label),
      subtitle: Text(DateFormat('yyyy-MM-dd HH:mm').format(initialDateTime)),
      trailing: const Icon(Icons.calendar_today),
      onTap: () async {
        // Show Date Picker
        DateTime? pickedDate = await showDatePicker(
          context: context,
          initialDate: initialDateTime,
          firstDate: DateTime(2000),
          lastDate: DateTime(2100),
        );
        if (pickedDate != null) {
          if(!context.mounted) return;
          // Show Time Picker after date is selected
          TimeOfDay? pickedTime = await showTimePicker(
            context: context,
            initialTime: TimeOfDay.fromDateTime(initialDateTime),
          );
          if (pickedTime != null) {
            // Combine the selected date and time into a single DateTime object
            DateTime newDateTime = DateTime(
              pickedDate.year,
              pickedDate.month,
              pickedDate.day,
              pickedTime.hour,
              pickedTime.minute,
            );
            onDateTimeChanged(newDateTime);
          }
        }
      },
    );
  }
}
