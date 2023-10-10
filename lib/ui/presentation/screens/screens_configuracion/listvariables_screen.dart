// ignore_for_file: unused_element

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:taxi_servicios/providers/configuracion_provider.dart';
import 'package:taxi_servicios/ui/presentation/screens/screens_configuracion/registrysetup_screen.dart';

class Configuration extends StatefulWidget {
  const Configuration({super.key});

  @override
  State<Configuration> createState() => _ConfigurationState();
}

class _ConfigurationState extends State<Configuration> {
  final TextEditingController myControllerName =
      TextEditingController(text: "");
  final TextEditingController myControllerValue =
      TextEditingController(text: "");

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
            onPressed: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const RegistryVariable()));

              //Navigator.pop(context, int.parse(myController.text));
            },
            child: const Text('Agregar ',
                style: TextStyle(
                  fontSize: 18,
                )))
      ],
    );
  }

  Widget _createListVariable(BuildContext context) {
    final listVariables = context.watch<ConfiguracionProvider>().listaVariables;
    return ListView.builder(
      itemCount: listVariables.length,
      itemBuilder: (BuildContext context, int index) {
        return ListTile(
            leading: const Icon(
              Icons.money_off,
              size: 30,
              color: Colors.green,
            ),
            title: Text(
              'COP ${listVariables[index].nombre}',
              style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black),
            ),
            subtitle: Text(
              '${listVariables[index].valor}',
              style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.normal,
                  color: Colors.black),
            ));
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
            title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Column(
              children: const [
                Text(
                  "Listado Variables de\nConfiguración",
                  textAlign: TextAlign.center,
                ),
              ],
            )
          ],
        )),
        body: _createListVariable(context),
        floatingActionButton: FloatingActionButton.extended(
          heroTag: 'btnagregar',
          backgroundColor: Colors.green,
          onPressed: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const RegistryVariable()));
          },
          icon: const Icon(Icons.playlist_add),
          label: const Text('Agregar Variable'),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat

        //const SizedBox(),

        /*const Padding(padding: EdgeInsets.all(20)),
        _createVariable('Entrega', 60000, Icons.money_off, Colors.green),
        _createVariable(
        'Gasolina', 60000, Icons.oil_barrel_rounded, Colors.red),
        _createVariable('Lavadero', 11000, Icons.wash, Colors.blue),
        _createVariable(
        'Sueldo', 134000, Icons.report_gmailerrorred, Colors.orange),*/

        );
  }
}
