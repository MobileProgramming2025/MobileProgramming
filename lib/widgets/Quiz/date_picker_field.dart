import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DatePickerField extends StatefulWidget {
  final String label;
  final DateTime initialDateTime;
  final ValueChanged<DateTime> onDateTimeChanged;

  const DatePickerField({
    super.key,
    required this.label,
    required this.initialDateTime,
    required this.onDateTimeChanged,
  });

  @override
  _DatePickerFieldState createState() => _DatePickerFieldState();
}

class _DatePickerFieldState extends State<DatePickerField> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(
      text: DateFormat('yyyy-MM-dd HH:mm').format(widget.initialDateTime),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _selectDateTime(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: widget.initialDateTime,
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );

    if (pickedDate == null) return;

    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(widget.initialDateTime),
    );

    if (pickedTime == null) return;

    final DateTime selectedDateTime = DateTime(
      pickedDate.year,
      pickedDate.month,
      pickedDate.day,
      pickedTime.hour,
      pickedTime.minute,
    );

    _controller.text = DateFormat('yyyy-MM-dd HH:mm').format(selectedDateTime);
    widget.onDateTimeChanged(selectedDateTime);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _selectDateTime(context),
      child: TextField(
        controller: _controller,
        enabled: false,
        decoration: InputDecoration(
          labelText: widget.label,
        ),
      ),
    );
  }
}
