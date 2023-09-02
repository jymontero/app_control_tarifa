// ignore: file_names
// ignore_for_file: unused_element, prefer_final_fields, unused_field

import 'package:flutter/material.dart';
import 'package:quickalert/quickalert.dart';

class GoalDairy extends StatefulWidget {
  const GoalDairy({super.key});

  @override
  State<GoalDairy> createState() => _GoalDairyState();
}

class _GoalDairyState extends State<GoalDairy> {
  late int _costService = 0;
  int _goal = 260000;
  int _currentGoal = 0;
  List<int> listServicesDay = [];

  void showAlert() {
    QuickAlert.show(
        context: context,
        title: "Error",
        text: "Valor del servicio Nulo",
        autoCloseDuration: const Duration(seconds: 3),
        confirmBtnText: "OK",
        type: QuickAlertType.error);
  }

  void showConfirmDialog() {
    QuickAlert.show(context: context, type: QuickAlertType.confirm);
  }

  Column _buildTextGoal(Color color, int monto) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Padding(padding: EdgeInsets.all(10.0)),
        Text(
          'COP \$ $monto',
          style: TextStyle(
            fontSize: 30,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _createInfolabels(String mensaje) {
    return Text(
      mensaje,
      textAlign: TextAlign.center,
      style: const TextStyle(color: Colors.white, fontSize: 14),
    );
  }

  Widget _createLabelRate(int metaActual, int flag) {
    if (flag == 0) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildTextGoal(Colors.lightGreenAccent.shade700, metaActual),
        ],
      );
    } else {
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildTextGoal(Colors.red, metaActual),
        ],
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Text("Impuestos");
  }
}
