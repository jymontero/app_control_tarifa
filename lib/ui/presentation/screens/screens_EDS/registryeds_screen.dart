import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pattern_formatter/pattern_formatter.dart';
import 'package:taxi_servicios/services/bd_confi.dart';
import 'package:taxi_servicios/ui/presentation/widgets/app_bar.dart';

import '../home_screen.dart';

class RegistryEDS extends StatefulWidget {
  const RegistryEDS({super.key});

  @override
  State<RegistryEDS> createState() => _RegistryEDSState();
}

class _RegistryEDSState extends State<RegistryEDS> {
  FireStoreDataBase bd = FireStoreDataBase();
  final TextEditingController myControllerNombre =
      TextEditingController(text: '');

  final TextEditingController myControllerBarrio =
      TextEditingController(text: '');

  final TextEditingController myControllerValorG =
      TextEditingController(text: '');

  final _formKeyEDS = GlobalKey<FormState>();

  Widget _createForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Form(
          key: _formKeyEDS,
          child: Column(
            children: [
              TextFormField(
                controller: myControllerNombre,
                textCapitalization: TextCapitalization.sentences,
                keyboardType: TextInputType.text,
                textInputAction: TextInputAction.next,
                inputFormatters: const [],
                validator: (controller) {
                  if (controller == null || controller.isEmpty) {
                    return 'Ingresa nombre de la EDS';
                  }
                  return null;
                },
                decoration: const InputDecoration(
                    prefixIcon: Align(
                      widthFactor: 1.0,
                      heightFactor: 1.0,
                      child: Icon(
                        Icons.table_chart_rounded,
                        color: Colors.green,
                      ),
                    ),
                    helperText: 'Nombre EDS',
                    helperStyle:
                        TextStyle(color: Colors.black38, fontSize: 14)),
              ),
              TextFormField(
                controller: myControllerBarrio,
                textCapitalization: TextCapitalization.sentences,
                keyboardType: TextInputType.text,
                textInputAction: TextInputAction.next,
                inputFormatters: const [],
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Ingrese Barrio EDS';
                  }
                  return null;
                },
                decoration: const InputDecoration(
                    prefixIcon: Align(
                      widthFactor: 1.0,
                      heightFactor: 1.0,
                      child: Icon(
                        Icons.location_city,
                        color: Colors.black,
                      ),
                    ),
                    helperText: 'Barrio EDS',
                    helperStyle:
                        TextStyle(color: Colors.black38, fontSize: 14)),
              ),
              TextFormField(
                controller: myControllerValorG,
                keyboardType: TextInputType.number,
                textInputAction: TextInputAction.done,
                inputFormatters: <TextInputFormatter>[
                  FilteringTextInputFormatter.digitsOnly,
                  ThousandsFormatter()
                ],
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Ingrese valor del galon';
                  }
                  return null;
                },
                decoration: const InputDecoration(
                    prefixIcon: Align(
                      widthFactor: 1.0,
                      heightFactor: 1.0,
                      child: Icon(
                        Icons.insert_chart_rounded,
                        color: Colors.red,
                      ),
                    ),
                    helperText: 'Ingrese valor del Galon',
                    helperStyle:
                        TextStyle(color: Colors.black38, fontSize: 14)),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _createRegistryButtom() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ElevatedButton(
            style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all(Colors.amber),
                foregroundColor: MaterialStateProperty.all(Colors.black),
                shape: MaterialStateProperty.all(RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5)))),
            onPressed: () async {
              if (_formKeyEDS.currentState!.validate()) {
                final String nombre = myControllerNombre.text;
                final String barrio = myControllerBarrio.text;
                final int galon =
                    int.parse(myControllerValorG.text.replaceAll(',', ''));

                await bd.addEDS(nombre, barrio, galon).then((_) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                      content: Text('Guardando base de datos....')));
                  Navigator.pop(context,
                      MaterialPageRoute(builder: (context) => const Home()));
                });
              }
            },
            child: const Text('Agregar EDS ',
                style: TextStyle(
                  fontSize: 18,
                )))
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: const AppBarCustomized(),
        body: SingleChildScrollView(
            padding: const EdgeInsets.all(30),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      height: 130,
                    ),
                    Text('Registro Estación De \nServicio',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold)),
                  ],
                ),
                _createForm(),
                const SizedBox(
                  height: 30,
                ),
                _createRegistryButtom()
              ],
            )));
  }
}
