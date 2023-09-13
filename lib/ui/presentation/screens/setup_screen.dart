import 'package:flutter/material.dart';

class Configuration extends StatefulWidget {
  const Configuration({super.key});

  @override
  State<Configuration> createState() => _ConfigurationState();
}

class _ConfigurationState extends State<Configuration> {
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

  Widget _createLabelRate(int metaActual, int flag) {
    if (flag == 0) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildTextGoal(Colors.lightGreenAccent.shade700, metaActual, 17),
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

  Widget _createInfolabels(String mensaje) {
    return Text(
      mensaje,
      textAlign: TextAlign.center,
      style: const TextStyle(color: Colors.black, fontSize: 16),
    );
  }

  Widget _createVariable(String name, int monto, IconData icono, Color color) {
    return Row(mainAxisAlignment: MainAxisAlignment.start, children: [
      Column(children: [
        Icon(
          icono,
          size: 50,
          color: color,
        ),
      ]),
      Column(children: [_createLabelRate(monto, 0), _createInfolabels(name)])
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SafeArea(
            child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          'Configuración De Variables',
          textAlign: TextAlign.center,
          style: TextStyle(
              fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black),
        ),
        const Padding(padding: EdgeInsets.all(20)),
        _createVariable('Entrega', 60000, Icons.money_off, Colors.green),
        _createVariable(
            'Gasolina', 60000, Icons.oil_barrel_rounded, Colors.red),
        _createVariable('Lavadero', 11000, Icons.wash, Colors.blue),
        _createVariable(
            'Sueldo', 134000, Icons.report_gmailerrorred, Colors.orange)
      ],
    )));
  }
}
