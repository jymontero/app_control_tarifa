// ignore_for_file: avoid_print, duplicate_ignore

import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:taxi_servicios/domain/entitis/servicio.dart';
import 'package:taxi_servicios/providers/contadordeservicios_provider.dart';
import 'package:taxi_servicios/providers/tanqueo_provider.dart';
import 'package:taxi_servicios/services/bd_confi.dart';
import 'package:taxi_servicios/ui/presentation/screens/home_screen.dart';
import 'package:taxi_servicios/ui/presentation/screens/screens_finturno/registrylavada_screen.dart';
import 'package:taxi_servicios/ui/presentation/screens/screens_finturno/registryentrega_screen.dart';
import 'package:taxi_servicios/ui/presentation/screens/screens_tanqueo/registrygas_screen.dart';
import 'package:taxi_servicios/ui/presentation/widgets/app_bar.dart';

class StepperFinalized extends StatefulWidget {
  const StepperFinalized({super.key});

  @override
  State<StepperFinalized> createState() => _StepperFinalizedState();
}

class _StepperFinalizedState extends State<StepperFinalized> {
  List<int> listaControlGananciaStepp = [];
  List<Servicio> listaServicios = [];
  int currentStep = 0;
  FireStoreDataBase db = FireStoreDataBase();
  DateTime selectedDate = DateTime.now().toLocal();
  int metaObtenida = 0;

  @override
  void initState() {
    initializeDateFormatting('es');
    final fechaTemp =
        '${selectedDate.day}-${selectedDate.month}-${selectedDate.year}'
            .toString();
    getDataServiciosToday(fechaTemp);

    super.initState();
  }

  void getDataServiciosToday(String date) async {
    List<Servicio> listaServicio = await db.getModeloServicios(date);
    if (listaServicio.isNotEmpty) {
      Future.microtask(() => context
          .read<ContadorServicioProvider>()
          .sumarListaServiciosBD(listaServicio, 'FINISH'));
    }
  }

  Widget _buildTextGoal(Color color, int monto, double sizeLetter) {
    final numberFormat =
        NumberFormat.currency(locale: 'es_MX', symbol: '\$', decimalDigits: 0);
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

  Widget _selectDate(BuildContext context) {
    return SizedBox(
      child: TextButton.icon(
          onPressed: () async {
            final DateTime? selected = await showDatePicker(
              context: context,
              locale: const Locale('es'),
              initialDate: selectedDate,
              firstDate: DateTime(2022),
              lastDate: DateTime(2030),
              initialEntryMode: DatePickerEntryMode.calendarOnly,
            );
            if (selected != null && selected != selectedDate) {
              setState(() {
                selectedDate = selected;
                final fechaTemp =
                    '${selectedDate.day}-${selectedDate.month}-${selectedDate.year}'
                        .toString();
                getDataServiciosToday(fechaTemp);
              });
            }
          },
          icon: const Icon(
            Icons.edit_calendar_outlined,
            size: 22,
            color: Colors.black,
          ),
          label: Text(
            DateFormat.yMMMEd('es').format(selectedDate),
            textAlign: TextAlign.center,
            style: const TextStyle(
                fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black),
          )),
    );
  }

  List<Step> getSpets() {
    return <Step>[
      Step(
          isActive: currentStep >= 0,
          state: currentStep > 0 ? StepState.complete : StepState.indexed,
          title: const Text('Tanqueo'),
          content: const SizedBox(
            width: 300,
            height: 200,
            child: RegistryGas(),
          )),
      Step(
          isActive: currentStep >= 1,
          state: currentStep > 1 ? StepState.complete : StepState.indexed,
          title: const Text('Entrega'),
          content: const SizedBox(
              width: 300, height: 100, child: RegistryEntrega())),
      Step(
          isActive: currentStep >= 2,
          state: currentStep > 2 ? StepState.complete : StepState.indexed,
          title: const Text('Lavada'),
          content: const SizedBox(
            width: 300,
            height: 110,
            child: RegistryLavada(),
          )),
      Step(
          isActive: currentStep >= 3,
          state: currentStep >= 3 ? StepState.complete : StepState.indexed,
          title: const Text('Ganancias'),
          content: SizedBox(
              width: 300,
              height: 110,
              child: Column(
                children: [
                  _buildTextGoal(
                      Colors.green,
                      context
                          .watch<ContadorServicioProvider>()
                          .metaObtenidaFinish,
                      20),
                ],
              )))
    ];
  }

  @override
  Widget build(BuildContext context) {
    final tanqueo =
        Provider.of<ServicioTanqueoProvider>(context, listen: false);

    int valorTanqueoProvider = 0;
    int valorEntregaProvider = 0;
    int valorLavadaProvider = 0;
    double valorGalones = 0;
    int valorKilometros = 0;

    return Scaffold(
        appBar: const AppBarCustomized(),
        body: Theme(
            data: Theme.of(context).copyWith(
              colorScheme: const ColorScheme.light(primary: Colors.blue),
            ),
            child: ListView(
              children: [
                const Text(
                  "Finalizar Turno",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 19, fontWeight: FontWeight.w700),
                ),
                _selectDate(context),
                _buildTextGoal(
                    Colors.purple,
                    context
                        .watch<ContadorServicioProvider>()
                        .metaObtenidaFinish,
                    20),
                Stepper(
                    type: StepperType.vertical,
                    currentStep: currentStep,
                    onStepContinue: () {
                      if (currentStep == 0) {
                        valorTanqueoProvider =
                            int.parse(tanqueo.valorTanqueo.replaceAll(',', ''));

                        context
                            .read<ContadorServicioProvider>()
                            .decrementarMetaObtenidaFinish(
                                valorTanqueoProvider);

                        listaControlGananciaStepp.add(valorTanqueoProvider);
                      }
                      if (currentStep == 1) {
                        valorEntregaProvider =
                            int.parse(tanqueo.valorEntrega.replaceAll(',', ''));
                        context
                            .read<ContadorServicioProvider>()
                            .decrementarMetaObtenidaFinish(
                                valorEntregaProvider);

                        listaControlGananciaStepp.add(valorEntregaProvider);
                      }
                      if (currentStep == 2) {
                        valorLavadaProvider =
                            int.parse(tanqueo.valorLavada.replaceAll(',', ''));
                        context
                            .read<ContadorServicioProvider>()
                            .decrementarMetaObtenidaFinish(valorLavadaProvider);

                        listaControlGananciaStepp.add(valorLavadaProvider);
                      }
                      if (currentStep == 3) {
                        // ignore: avoid_print
                        final serviciosProvider =
                            Provider.of<ContadorServicioProvider>(context,
                                listen: false);

                        int ganancia = serviciosProvider.metaObtenidaFinish;

                        valorTanqueoProvider =
                            int.parse(tanqueo.valorTanqueo.replaceAll(',', ''));

                        valorGalones = double.parse(
                            tanqueo.valorGalones.replaceAll(',', '.'));

                        valorKilometros = int.parse(tanqueo.valorKilometros);

                        //enviando base de datos
                        db.addGananciaBD(
                            ganancia,
                            selectedDate.day.toString(),
                            selectedDate.month.toString(),
                            selectedDate.year.toString());

                        db.addTanqueoBD(
                            valorTanqueoProvider,
                            valorKilometros,
                            valorGalones,
                            '${selectedDate.day}-${selectedDate.month}-${selectedDate.year}',
                            '${selectedDate.hour}:${selectedDate.minute}:${selectedDate.second}');

                        Navigator.pop(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const Home()));
                      } else {
                        setState(() {
                          currentStep++;
                        });
                      }
                    },
                    onStepCancel: () {
                      if (currentStep <= 0) return;
                      setState(() {
                        currentStep--;
                        int restar =
                            listaControlGananciaStepp.elementAt(currentStep);

                        listaControlGananciaStepp.removeAt(currentStep);

                        context
                            .read<ContadorServicioProvider>()
                            .incrementarMetaObtenidaFinish(restar);
                      });
                    },
                    controlsBuilder: (context, ControlsDetails details) {
                      return Row(
                        children: <Widget>[
                          Expanded(
                              child: ElevatedButton(
                            onPressed: details.onStepContinue,
                            style: ButtonStyle(
                                backgroundColor:
                                    MaterialStateProperty.all(Colors.amber),
                                foregroundColor:
                                    MaterialStateProperty.all(Colors.black),
                                shape: MaterialStateProperty.all(
                                    RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(5)))),
                            child: Text(
                              currentStep == 3 ? 'CONFIRMAR' : 'Continuar',
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                  fontSize: 13, fontWeight: FontWeight.bold),
                            ),
                          )),
                          const SizedBox(width: 10),
                          if (currentStep != 0)
                            Expanded(
                              child: ElevatedButton(
                                onPressed: details.onStepCancel,
                                style: ButtonStyle(
                                    backgroundColor:
                                        MaterialStateProperty.all(Colors.amber),
                                    foregroundColor:
                                        MaterialStateProperty.all(Colors.black),
                                    shape: MaterialStateProperty.all(
                                        RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(5)))),
                                child: const Text('Atras'),
                              ),
                            ),
                        ],
                      );
                    },
                    steps: getSpets()),
              ],
            )));
  }
}
