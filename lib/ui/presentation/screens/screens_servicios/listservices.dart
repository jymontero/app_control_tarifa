//import 'package:cloud_firestore/cloud_firestore.dart';
// ignore_for_file: unused_element

import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:taxi_servicios/domain/entitis/servicio.dart';
import 'package:taxi_servicios/providers/contadordeservicios_provider.dart';
import 'package:taxi_servicios/services/bd_confi.dart';
import 'package:taxi_servicios/ui/presentation/screens/screens_ganancias/homeganancia.dart';

class ListService extends StatefulWidget {
  const ListService({super.key});

  @override
  State<ListService> createState() => _ListServiceState();
}

class _ListServiceState extends State<ListService> {
  late List<Servicio> listaServicios = [];
  var time = DateTime.now();
  DateTime selectedDate = DateTime.now().toLocal();

  FireStoreDataBase bd = FireStoreDataBase();

  final numberFormat =
      NumberFormat.currency(locale: 'es_MX', symbol: '\$', decimalDigits: 0);

  @override
  void initState() {
    initializeDateFormatting('es');

    super.initState();
  }

  int sumarListaBd(List<Servicio> lista) {
    listaServicios = lista;
    int sumar = 0;
    for (var item in listaServicios) {
      int aux = item.valorservicio;
      sumar += aux;
    }
    return sumar;
  }

  Widget _createInfolabels(String mensaje) {
    return Text(
      mensaje,
      textAlign: TextAlign.center,
      style: const TextStyle(
          fontSize: 21, fontWeight: FontWeight.bold, color: Colors.black),
    );
  }

  Widget _createFutureBuilder() {
    final fechaTemp =
        '${selectedDate.day}-${selectedDate.month}-${selectedDate.year}'
            .toString();
    /*Future.microtask(
        () => context.read<ContadorServicioProvider>().setMetaObtenida());*/

    return FutureBuilder(
        future: bd.getModeloServicios(fechaTemp),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Text("AlgoMaloPaso");
          }
          if (snapshot.hasData) {
            listaServicios = snapshot.data!;

            /*Future.microtask(() => context
                .read<ContadorServicioProvider>()
                .incrementarMeta(sumarListaBd(listaServicios)));

            Future.microtask(() => context
                .read<ContadorServicioProvider>()
                .decrementarMeta((sumarListaBd(listaServicios))));*/

            return _crearListaServiciosBD(context);
          }
          return const Center(child: CircularProgressIndicator());
        });
  }

  Widget _crearListaServiciosBD(BuildContext context) {
    if (listaServicios.isEmpty) {
      return const Text(
        'No hay Servicios Registrados para esta fecha',
        textAlign: TextAlign.center,
      );
    } else {
      return ListView.builder(
        padding: const EdgeInsets.only(left: 5, top: 0, right: 0, bottom: 70),
        shrinkWrap: true,
        itemCount: listaServicios.length,
        itemBuilder: (BuildContext context, int index) {
          return ListTile(
            leading: const Icon(
              Icons.local_taxi_rounded,
              size: 25,
              color: Colors.black,
            ),
            title: Text(
              'COP ${numberFormat.format(listaServicios[index].valorservicio)}',
              style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black),
            ),
            subtitle: Text(
              '${listaServicios[index].fecha}\t\t\t${listaServicios[index].hora}',
              style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.normal,
                  color: Colors.black),
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                    onPressed: () {},
                    icon: const Icon(
                      Icons.mode_edit_outline_outlined,
                      color: Colors.green,
                    )),
                IconButton(
                    onPressed: () async {
                      await showDialog(
                          context: context,
                          builder: (context) {
                            return AlertDialog(
                              title: const Text('Desesa Eliminar el servicio'),
                              actionsAlignment: MainAxisAlignment.spaceBetween,
                              actions: [
                                TextButton(
                                    onPressed: () {
                                      bd.eliminarServicio(
                                          listaServicios[index].id);
                                      /* Navigator.pop(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  const Home()));*/
                                      Navigator.pop(context, true);
                                    },
                                    child: const Text('Si')),
                                TextButton(
                                    onPressed: () {
                                      Navigator.pop(context, false);
                                    },
                                    child: const Text('NO'))
                              ],
                            );
                          });
                    },
                    icon: const Icon(Icons.delete_forever, color: Colors.red)),
              ],
            ),
          );
        },
      );
    }
  }

  Widget _createListServiceP(BuildContext context) {
    final listServices = context
        .watch<ContadorServicioProvider>()
        .listaServicios
        .reversed
        .toList();
    return ListView.builder(
      padding: const EdgeInsets.only(left: 5, top: 0, right: 0, bottom: 70),
      shrinkWrap: true,
      itemCount: listServices.length,
      itemBuilder: (BuildContext context, int index) {
        return ListTile(
          leading: const Icon(
            Icons.local_taxi_rounded,
            size: 25,
            color: Colors.black,
          ),
          title: Text(
            'COP ${numberFormat.format(listServices[index].valorservicio)}',
            style: const TextStyle(
                fontSize: 17, fontWeight: FontWeight.bold, color: Colors.black),
          ),
          subtitle: Text(
            '${listServices[index].fecha}\t\t\t${listServices[index].hora}',
            style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.normal,
                color: Colors.black),
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                  onPressed: () {},
                  icon: const Icon(
                    Icons.mode_edit_outline_outlined,
                    color: Colors.green,
                  )),
              IconButton(
                  onPressed: () {},
                  icon: const Icon(Icons.delete_forever, color: Colors.red)),
            ],
          ),
        );
      },
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
                Future.microtask(() =>
                    context.read<ContadorServicioProvider>().setMetaObtenida());
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
            title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Column(
              children: [
                const SizedBox(height: 15),
                const Text(
                  "Listado De Servicios",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                ),
                _selectDate(context)
              ],
            )
          ],
        )),
        body: SizedBox(child: _createFutureBuilder()),
        floatingActionButton: FloatingActionButton.extended(
          heroTag: 'btnagregar',
          backgroundColor: Colors.green,
          onPressed: () {
            Navigator.push(context,
                MaterialPageRoute(builder: (context) => const HomeGanancia()));
          },
          icon: const Icon(Icons.playlist_add),
          label: const Text('Ver Ingresos'),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat);
  }
}
