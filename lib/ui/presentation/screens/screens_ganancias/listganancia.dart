import 'package:flutter/material.dart';
import 'package:taxi_servicios/ui/presentation/widgets/app_bar.dart';

class GananciaList extends StatefulWidget {
  const GananciaList({super.key});

  @override
  State<GananciaList> createState() => _GananciaListState();
}

class _GananciaListState extends State<GananciaList> {
  String date = "";

  DateTime selectedDate = DateTime.now();

  _selectDate(BuildContext context) async {
    final DateTime? selected = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2010),
      lastDate: DateTime(2025),
      initialEntryMode: DatePickerEntryMode.calendarOnly,
    );
    if (selected != null && selected != selectedDate) {
      setState(() {
        selectedDate = selected;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: const AppBarCustomized(),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              ElevatedButton(
                onPressed: () {
                  _selectDate(context);
                },
                child: const Text("Choose Date"),
              ),
              Text(
                  "${selectedDate.day}/${selectedDate.month}/${selectedDate.year}")
            ],
          ),
        ));
  }
}
