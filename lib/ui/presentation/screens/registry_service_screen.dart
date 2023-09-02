// ignore: file_names
// ignore_for_file: no_leading_underscores_for_local_identifiers, avoid_print, unused_element

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:taxi_servicios/ui/presentation/widgets/app_bar.dart';

class ServiceTaxi extends StatefulWidget {
  const ServiceTaxi({super.key});

  @override
  State<ServiceTaxi> createState() => _ServiceTaxiState();
}

class _ServiceTaxiState extends State<ServiceTaxi> {
  var time = DateTime.now();

  //final myController = TextEditingController();
  final TextEditingController myController = TextEditingController(text: "");

  @override
  Widget build(BuildContext context) {
    Widget _createInputService() {
      return Column(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            child: TextField(
              autofocus: false,
              style: const TextStyle(color: Colors.black),
              controller: myController,
              keyboardType: TextInputType.number,
              inputFormatters: <TextInputFormatter>[
                FilteringTextInputFormatter.digitsOnly,
              ],
              decoration: const InputDecoration(
                helperText: 'Ingrese valor del servicio',
                helperStyle: TextStyle(color: Colors.black, fontSize: 18),
              ),
            ),
          ),
        ],
      );
    }

    Widget _createlabelDate() {
      return Row(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            child: Text(
              'Hora del Viaje\n${time.hour}:${time.minute}:${time.second}',
              style: const TextStyle(fontSize: 18),
            ),
          )
        ],
      );
    }

    Widget _createInputDate() {
      return Row(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            child: Text(
                'Fecha del Viaje \n${time.day}/${time.month}/${time.year}',
                style: const TextStyle(fontSize: 18)),
          )
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
                  foregroundColor: MaterialStateProperty.all(Colors.black)),
              onPressed: () {
                Navigator.pop(context, int.parse(myController.text));
              },
              child: const Text('Agregar Viaje',
                  style: TextStyle(
                    fontSize: 18,
                  )))
        ],
      );
    }

    return Scaffold(
      appBar: const AppBarCustomized(),
      body: Column(
        children: [
          _createInputService(),
          _createlabelDate(),
          _createInputDate(),
          _createRegistryButtom()
        ],
      ),
    );
  }
}
