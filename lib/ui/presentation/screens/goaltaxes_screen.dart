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

  Column _buildTextGoal(Color color, int monto, double sizeLetter) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Padding(padding: EdgeInsets.all(10.0)),
        Text(
          'COP \$ $monto',
          style: TextStyle(
            fontSize: sizeLetter,
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
      style: const TextStyle(color: Colors.black, fontSize: 16),
    );
  }

  Widget _createLabelRate(int metaActual, int flag) {
    if (flag == 0) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildTextGoal(Colors.lightGreenAccent.shade700, metaActual, 20),
        ],
      );
    } else {
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildTextGoal(Colors.red, metaActual, 20),
        ],
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildTextGoal(Colors.black, 260000, 30),
        _createInfolabels('Meta x Hacer'),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Column(
              children: [
                _createLabelRate(260000, 1),
                _createInfolabels('Meta Registrada'),
              ],
            ),
            const Padding(padding: EdgeInsets.all(15)),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _createLabelRate(20000, 0),
                _createInfolabels('Meta obtenida'),
              ],
            )
          ],
        )
      ],
    ));
  }
}
