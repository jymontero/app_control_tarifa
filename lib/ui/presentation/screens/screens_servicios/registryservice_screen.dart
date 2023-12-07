import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:quickalert/quickalert.dart';
import 'package:taxi_servicios/providers/contadordeservicios_provider.dart';
import 'package:taxi_servicios/services/bd_confi.dart';
import 'package:taxi_servicios/ui/presentation/screens/screens_servicios/listservices_screen.dart';
import 'package:taxi_servicios/ui/presentation/widgets/app_bar.dart';
import 'package:pattern_formatter/pattern_formatter.dart';

class ServiceTaxi extends StatefulWidget {
  const ServiceTaxi({super.key});

  @override
  State<ServiceTaxi> createState() => _ServiceTaxiState();
}

class _ServiceTaxiState extends State<ServiceTaxi> {
  DateTime time = DateTime.now().toLocal();
  final TextEditingController myController = TextEditingController(text: "");
  final numberFormat =
      NumberFormat.currency(locale: 'es_MX', symbol: '\$', decimalDigits: 0);

  FireStoreDataBase db = FireStoreDataBase();

  @override
  void initState() {
    initializeDateFormatting('es');

    super.initState();
  }

  Widget _selectDate(BuildContext context) {
    return SizedBox(
      child: TextButton.icon(
          onPressed: () async {
            final DateTime? selected = await showDatePicker(
              context: context,
              locale: const Locale('es'),
              initialDate: time,
              firstDate: DateTime(2022),
              lastDate: DateTime(2030),
              initialEntryMode: DatePickerEntryMode.calendarOnly,
            );
            if (selected != null && selected != time) {
              setState(() {
                time = selected;
              });
            }
          },
          icon: const Icon(
            Icons.calendar_month,
            size: 22,
            color: Colors.black,
          ),
          label: Text(
            DateFormat.yMMMEd('es').format(time),
            style: const TextStyle(
                fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black),
          )),
    );
  }

  void showAlert() {
    QuickAlert.show(
        context: context,
        title: "Valor del servicio",
        text: "Ingrese un valor mayor a \nCOP ${0.0}",
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
              ThousandsFormatter()
            ],
            decoration: const InputDecoration(
              prefixIcon: Align(
                widthFactor: 1.0,
                heightFactor: 1.0,
                child: Icon(
                  Icons.monetization_on,
                  color: Colors.green,
                ),
              ),
              helperText: 'Ingrese valor del servicio',
              helperStyle: TextStyle(color: Colors.black, fontSize: 16),
            ),
          ),
        ),
      ],
    );
  }

  Widget _createlabelDate() {
    String hora = DateFormat.jm().format(time);

    return Column(
      children: [
        const Text(
          'Hora del Viaje',
          style: TextStyle(fontSize: 16),
        ),
        Container(
          padding: const EdgeInsets.all(13),
          child: Text(
            // '${time.hour}:${time.minute}:${time.second}',
            hora,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }

  Widget _createInputDate() {
    return Column(
      children: [
        const Text(
          'Fecha del Viaje',
          style: TextStyle(fontSize: 16),
        ),
        _selectDate(context)
        /*Container(
            padding: const EdgeInsets.all(10), child: _selectDate(context))*/
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
              final valor = myController.text.replaceAll(',', '');
              if (myController.text.isEmpty) {
                showAlert();
              } else {
                await showDialog(
                  context: context,
                  builder: (context) {
                    return AlertDialog(
                      title: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const Text(
                            'Registrar ',
                            textAlign: TextAlign.center,
                          ),
                          Text(
                            'COP ${numberFormat.format(int.parse(valor))}',
                            textAlign: TextAlign.center,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      actionsAlignment: MainAxisAlignment.spaceBetween,
                      actions: [
                        TextButton(
                          onPressed: () {
                            String hora = DateFormat.jm().format(time);

                            final horaTemp = hora;
                            //'${time.hour}:${time.minute}:${time.second}';
                            final fechaTemp =
                                '${time.day}-${time.month}-${time.year}';

                            context
                                .read<ContadorServicioProvider>()
                                .incrementarMetaObtenida(int.parse(valor));

                            context
                                .read<ContadorServicioProvider>()
                                .decrementarMetaPorHacer(int.parse(valor));

                            //Base de datos
                            db.addServicioBD(
                                fechaTemp, horaTemp, int.parse(valor));

                            ///
                            ///
                            Navigator.pop(context, true);
                            Navigator.pop(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => const ListService()));
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
              }
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
          const Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            Text(
              'Registro De Servicio',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ]),
          _createInputService(),
          const SizedBox(height: 10),
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
