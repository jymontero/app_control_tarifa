// ignore: file_names
// ignore_for_file: no_leading_underscores_for_local_identifiers, avoid_print, unused_element

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:quickalert/quickalert.dart';
import 'package:taxi_servicios/domain/entitis/servicio.dart';
import 'package:taxi_servicios/providers/contadorservicio_provider.dart';
import 'package:taxi_servicios/ui/presentation/screens/home_screen.dart';
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
  final numberFormat =
      NumberFormat.currency(locale: 'es_MX', symbol: '\$', decimalDigits: 0);

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

  Widget _createInputService() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          child: TextFormField(
            autofocus: false,
            style: const TextStyle(color: Colors.black),
            controller: myController,
            keyboardType: TextInputType.number,
            inputFormatters: <TextInputFormatter>[
              FilteringTextInputFormatter.digitsOnly,
            ],
            decoration: const InputDecoration(
              helperText: 'Ingrese valor del servicio',
              helperStyle: TextStyle(color: Colors.black, fontSize: 16),
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
            style: const TextStyle(fontSize: 16),
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
          child:
              Text('Fecha del Viaje \n${time.day}/${time.month}/${time.year}',
                  style: const TextStyle(
                    fontSize: 16,
                  )),
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
                foregroundColor: MaterialStateProperty.all(Colors.black),
                shape: MaterialStateProperty.all(RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5)))),
            onPressed: () {
              Servicio servicio = Servicio(
                  valorservicio: int.parse(myController.text),
                  hora: '${time.day}/${time.month}/${time.year}',
                  fecha: '${time.hour}:${time.minute}:${time.second}');
              context
                  .read<ContadorServicioProvider>()
                  .incrementarMeta(int.parse(myController.text));

              context
                  .read<ContadorServicioProvider>()
                  .decrementarMeta(int.parse(myController.text));

              context.read<ContadorServicioProvider>().addServicio(servicio);
              Navigator.pop(context,
                  MaterialPageRoute(builder: (context) => const Home()));
            },
            child: const Text('Agregar Viaje',
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
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(mainAxisAlignment: MainAxisAlignment.center, children: const [
            Text(
              'Registro De Servicio',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ]),
          _createInputService(),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Column(
                children: [
                  _createlabelDate(),
                ],
              ),
              Column(
                children: [
                  _createInputDate(),
                ],
              )
            ],
          ),
          const Padding(padding: EdgeInsets.all(20)),
          _createRegistryButtom()
        ],
      ),
    );
  }
}
