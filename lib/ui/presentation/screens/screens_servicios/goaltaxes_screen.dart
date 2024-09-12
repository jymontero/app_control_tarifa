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

  Column _textoMontoMetaPorHacer(Color color, int monto, double sizeLetter) {
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

  Widget _etiquetasTexto(String mensaje) {
    return Text(
      mensaje,
      textAlign: TextAlign.center,
      style: const TextStyle(color: Colors.black, fontSize: 16),
    );
  }

  Widget _textoMetaRegistrada(int metaActual, int flag) {
    if (flag == 0) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _textoMontoMetaPorHacer(
              Colors.lightGreenAccent.shade700, metaActual, 22),
        ],
      );
    } else {
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _textoMontoMetaPorHacer(Colors.deepPurple, metaActual, 22),
        ],
      );
    }
  }

  Widget _card() {
    return Center(
        child: Card(
            elevation: 4.0,
            margin: const EdgeInsets.all(10),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                const SizedBox(
                  height: 50,
                  child: ListTile(
                    title: Text(
                      "Detalles",
                      textAlign: TextAlign.center,
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                SizedBox(
                  height: 45,
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 15.0, vertical: -55),
                    leading: const Icon(
                      Icons.flag_circle,
                      size: 30,
                      color: Color.fromARGB(255, 231, 45, 31),
                    ),
                    title: const Text(
                      "Meta Registrada",
                      textAlign: TextAlign.left,
                    ),
                    trailing: Text(
                      numberFormat.format(context
                          .watch<ConfiguracionProvider>()
                          .metaRegistradaBD),
                      textAlign: TextAlign.right,
                      style: const TextStyle(
                          fontSize: 17, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),

                //Divider(height: 1), // Línea divisoria entre ListTiles

                SizedBox(
                  //height: 45,
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 15.0, vertical: 0),
                    leading: const Icon(
                      Icons.flag_circle,
                      size: 30,
                      color: Color.fromARGB(255, 119, 15, 138),
                    ),
                    title: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Column(
                          children: [
                            Text(
                              "Meta por Hacer",
                              textAlign: TextAlign.left,
                            )
                          ],
                        ),
                        Column(
                          children: [
                            Text(
                              numberFormat.format(context
                                  .watch<ContadorServicioProvider>()
                                  .configuracion),
                              textAlign: TextAlign.right,
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold),
                            )
                          ],
                        )
                      ],
                    ),
                  ),
                ),
                const Divider(height: 1), // Línea divisoria entre ListTiles

                ListTile(
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 15.0, vertical: 0),
                  leading: const Icon(
                    Icons.flag_circle,
                    size: 30,
                    color: Colors.green,
                  ),
                  title: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Column(
                        children: [
                          Text(
                            "Meta Obtenida",
                            textAlign: TextAlign.left,
                          )
                        ],
                      ),
                      Column(
                        children: [
                          Text(
                            numberFormat.format(context
                                .watch<ContadorServicioProvider>()
                                .valorMetaObtenida),
                            textAlign: TextAlign.right,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          )
                        ],
                      )
                    ],
                  ),
                )
              ],
            )));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: const Color(0xffd6d6cd),
        //backgroundColor: const Color.fromARGB(255, 206, 214, 205),
        body: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _card(),
            const Row(
              children: [Text('Historial')],
            ),
//            const ListService(),
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





/**
 * 
 *  _textoMontoMetaPorHacer(Colors.red,
                context.watch<ContadorServicioProvider>().configuracion, 30),
            _etiquetasTexto('Meta x Hacer'),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Column(
                  children: [
                    _textoMetaRegistrada(
                        context.watch<ConfiguracionProvider>().metaRegistradaBD,
                        1),
                    _etiquetasTexto('Meta Registrada'),
                  ],
                ),
                const Padding(padding: EdgeInsets.all(15)),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _textoMetaRegistrada(
                        context
                            .watch<ContadorServicioProvider>()
                            .valorMetaObtenida,
                        0),
                    _etiquetasTexto('Meta obtenida'),
                  ],
                )
              ],
            )
 */



/**
 * 
 * 
 * Row(
                children: [

                        ListTile(
                  //leading: Icon(Icons.album),
                  title: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Detalles",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold),
                      )
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Column(
                        children: [
                          Text(
                            "Meta Registrada",
                            textAlign: TextAlign.left,
                          )
                        ],
                      ),
                      Column(
                        children: [
                          Text(
                            numberFormat.format(context
                                .watch<ConfiguracionProvider>()
                                .metaRegistradaBD),
                            textAlign: TextAlign.right,
                          )
                        ],
                      )
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Column(
                        children: [
                          Text(
                            "Meta por Hacer",
                            textAlign: TextAlign.left,
                          )
                        ],
                      ),
                      Column(
                        children: [
                          Text(
                            numberFormat.format(context
                                .watch<ContadorServicioProvider>()
                                .configuracion),
                            textAlign: TextAlign.right,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          )
                        ],
                      )
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Column(
                        children: [
                          Text(
                            "Meta Obtenida",
                            textAlign: TextAlign.left,
                          )
                        ],
                      ),
                      Column(
                        children: [
                          Text(
                            numberFormat.format(context
                                .watch<ContadorServicioProvider>()
                                .valorMetaObtenida),
                            textAlign: TextAlign.right,
                          )
                        ],
                      )
                    ],
                  )
                ],
              ))),

 */