// ignore_for_file: unused_element

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pattern_formatter/pattern_formatter.dart';
import 'package:provider/provider.dart';
import 'package:taxi_servicios/providers/tanqueo_provider.dart';
import 'package:taxi_servicios/services/bd_confi.dart';
import 'package:taxi_servicios/ui/presentation/screens/home_screen.dart';

class RegistryGas extends StatefulWidget {
  const RegistryGas({super.key});

  @override
  State<RegistryGas> createState() => _RegistryGasState();
}

class _RegistryGasState extends State<RegistryGas> {
  final TextEditingController myControllerValue =
      TextEditingController(text: "");

  final TextEditingController myControllerGalones =
      TextEditingController(text: "");

  final TextEditingController myControllerKm = TextEditingController(text: "");

  final TextEditingController myControllerEstacion =
      TextEditingController(text: "");

  final _formKeyGas = GlobalKey<FormState>();

  @override
  void initState() {
    myControllerValue.addListener(() {
      context
          .read<ServicioTanqueoProvider>()
          .setvalorTanqueo((myControllerValue.text));
    });
    myControllerGalones.addListener(() {
      context
          .read<ServicioTanqueoProvider>()
          .setvalorGalones(myControllerGalones.text);
    });

    myControllerKm.addListener(() {
      context
          .read<ServicioTanqueoProvider>()
          .setvalorKilometraje(myControllerKm.text);
    });
    super.initState();
  }

  @override
  void dispose() {
    myControllerValue.dispose();
    myControllerEstacion.dispose();
    myControllerKm.dispose();
    myControllerGalones.dispose();
    super.dispose();
  }

  Widget _createForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Form(
          key: _formKeyGas,
          child: Column(
            children: [
              TextFormField(
                controller: myControllerValue,
                keyboardType: TextInputType.number,
                textInputAction: TextInputAction.next,
                inputFormatters: <TextInputFormatter>[
                  FilteringTextInputFormatter.digitsOnly,
                  ThousandsFormatter()
                ],
                validator: (controller) {
                  if (controller == null || controller.isEmpty) {
                    return 'Ingresa valor del tanqueo';
                  }
                  return null;
                },
                decoration: const InputDecoration(
                    prefixIcon: Align(
                      widthFactor: 1.0,
                      heightFactor: 1.0,
                      child: Icon(
                        Icons.monetization_on,
                        color: Colors.green,
                      ),
                    ),
                    hintText: 'Valor Tanqueo',
                    hintStyle: TextStyle(color: Colors.black38, fontSize: 14)),
              ),
              TextFormField(
                controller: myControllerGalones,
                keyboardType: TextInputType.number,
                textInputAction: TextInputAction.next,
                inputFormatters: const [],
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Ingrese No de Galones';
                  }
                  return null;
                },
                decoration: const InputDecoration(
                    prefixIcon: Align(
                      widthFactor: 1.0,
                      heightFactor: 1.0,
                      child: Icon(
                        Icons.oil_barrel,
                        color: Colors.black,
                      ),
                    ),
                    hintText: 'No Galones',
                    hintStyle: TextStyle(color: Colors.black38, fontSize: 14)),
              ),
              TextFormField(
                controller: myControllerKm,
                keyboardType: TextInputType.number,
                textInputAction: TextInputAction.done,
                inputFormatters: <TextInputFormatter>[
                  FilteringTextInputFormatter.digitsOnly,
                  ThousandsFormatter()
                ],
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Kilometraje';
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
                    hintText: 'Ingrese Kilometraje',
                    hintStyle: TextStyle(color: Colors.black38, fontSize: 14)),
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
              if (_formKeyGas.currentState!.validate()) {
                final int valor =
                    int.parse(myControllerValue.text.replaceAll(',', ''));
                final int km = int.parse(myControllerKm.text);
                final double galon = double.parse(myControllerGalones.text);

                //context.read<ConfiguracionProvider>().addVariable(variable);
                await addTanqueoBD(valor, km, galon).then((_) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                      content: Text('Guardando base de datos....')));
                  Navigator.pop(context,
                      MaterialPageRoute(builder: (context) => const Home()));
                });
              }

              //Navigator.pop(context, int.parse(myController.text));
            },
            child: const Text('Agregar ',
                style: TextStyle(
                  fontSize: 18,
                )))
      ],
    );
  }

  /*Widget _dropButton() {
    final List<DropdownMenuEntry<String>> entradaEstacion =
        <DropdownMenuEntry<String>>[];
    return const DropdownMenu(dropdownMenuEntries: entradaEstacion);
  }*/

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  /*Text(
                    'Registro De Tanqueo',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  )*/
                ],
              ),
              //const Padding(padding: EdgeInsets.all(15)),
              _createForm(),
              //const Padding(padding: EdgeInsets.all(20)),
              //_createRegistryButtom()
            ]),
      ),
    );
  }
}
