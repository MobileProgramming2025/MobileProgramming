import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DatePickerField extends StatelessWidget {
  final String label;
  final DateTime initialDateTime;
  final ValueChanged<DateTime> onDateTimeChanged;

  const DatePickerField({
    super.key,
    required this.label,
    required this.initialDateTime,
    required this.onDateTimeChanged,
  });

  Future<void> _selectDateTime(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: initialDateTime,
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );

    if (pickedDate == null) return;

    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(initialDateTime),
    );

    if (pickedTime == null) return;

    onDateTimeChanged(
      DateTime(
        pickedDate.year,
        pickedDate.month,
        pickedDate.day,
        pickedTime.hour,
        pickedTime.minute,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _selectDateTime(context),
      child: TextField(
        enabled: false,
        decoration: InputDecoration(
          labelText: label,
          hintText: DateFormat('yyyy-MM-dd HH:mm').format(initialDateTime),
        ),
      ),
    );
  }
}
