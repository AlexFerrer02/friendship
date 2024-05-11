import 'package:flutter/material.dart';

class DateTimePicker extends StatefulWidget {
  final Function(DateTime) onDateTimeSelected;

  DateTimePicker({required this.onDateTimeSelected});

  @override
  _DateTimePickerState createState() => _DateTimePickerState();
}

class _DateTimePickerState extends State<DateTimePicker> {
  DateTime _selectedDateTime = DateTime.now();

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ElevatedButton(
          onPressed: () async {
            final selectedDate = await showDatePicker(
              context: context,
              initialDate: _selectedDateTime,
              firstDate: DateTime(2000),
              lastDate: DateTime(2101),
            );

            if (selectedDate != null) {
              final selectedTime = await showTimePicker(
                context: context,
                initialTime: TimeOfDay.fromDateTime(_selectedDateTime),
              );

              if (selectedTime != null) {
                final newDateTime = DateTime(
                  selectedDate.year,
                  selectedDate.month,
                  selectedDate.day,
                  selectedTime.hour,
                  selectedTime.minute,
                );
                setState(() {
                  _selectedDateTime = newDateTime;
                });
                widget.onDateTimeSelected(newDateTime);
              }
            }
          },
          child: const Text('Seleccionar Fecha y Hora'),
        ),
        Text(
          'Fecha y Hora seleccionadas: $_selectedDateTime',
          style: const TextStyle(fontSize: 16),
        ),
      ],
    );
  }
}