// ignore: file_names
// ignore_for_file: unused_element, prefer_final_fields, unused_field

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:taxi_servicios/providers/configuracion_provider.dart';
import 'package:taxi_servicios/providers/contadordeservicios_provider.dart';
import 'package:intl/intl.dart';
import 'package:taxi_servicios/ui/presentation/screens/screens_finturno/finish_screen.dart';

class GoalDairy extends StatefulWidget {
  const GoalDairy({super.key});

  @override
  State<GoalDairy> createState() => _GoalDairyState();
}

class _GoalDairyState extends State<GoalDairy> {
  @override
  void initState() {
    super.initState();
  }

  final numberFormat =
      NumberFormat.currency(locale: 'es_MX', symbol: '\$', decimalDigits: 0);

  Column _buildTextGoal(Color color, int monto, double sizeLetter) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Padding(padding: EdgeInsets.all(10.0)),
        Text(
          'COP ${numberFormat.format(monto)}',
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
          _buildTextGoal(Colors.lightGreenAccent.shade700, metaActual, 22),
        ],
      );
    } else {
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildTextGoal(Colors.deepPurple, metaActual, 22),
        ],
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        //backgroundColor: const Color.fromARGB(255, 206, 214, 205),
        body: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildTextGoal(Colors.red,
                context.watch<ContadorServicioProvider>().configuracion, 30),
            _createInfolabels('Meta x Hacer'),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Column(
                  children: [
                    _createLabelRate(
                        context.watch<ConfiguracionProvider>().metaRegistradaBD,
                        1),
                    _createInfolabels('Meta Registrada'),
                  ],
                ),
                const Padding(padding: EdgeInsets.all(15)),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _createLabelRate(
                        context
                            .watch<ContadorServicioProvider>()
                            .valorMetaObtenida,
                        0),
                    _createInfolabels('Meta obtenida'),
                  ],
                )
              ],
            )
          ],
        ),
        floatingActionButton: FloatingActionButton.extended(
          heroTag: 'btnFinalizarTurno',
          backgroundColor: Colors.red,
          onPressed: () async {
            await showDialog(
              context: context,
              builder: (context) {
                return AlertDialog(
                  title: const Text(
                    'Finalizar Turno ?',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  actionsAlignment: MainAxisAlignment.spaceBetween,
                  actions: [
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context, true);

                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                // ignore: prefer_const_constructors
                                builder: (context) => StepperFinalized()));
                      },
                      child: const Text('Si'),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context, false);
                      },
                      child: const Text('No'),
                    ),
                  ],
                );
              },
            );
          },
          icon: const Icon(
            Icons.output_outlined,
          ),
          label: const Text('Finalizar Turno'),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat);
  }
}
