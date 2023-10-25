//import 'package:cloud_firestore/cloud_firestore.dart';
// ignore_for_file: unused_element

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:taxi_servicios/providers/contadorservicio_provider.dart';
import 'package:taxi_servicios/ui/presentation/screens/screens_ganancias/listganancia.dart';

class ListService extends StatefulWidget {
  const ListService({super.key});

  @override
  State<ListService> createState() => _ListServiceState();
}

class _ListServiceState extends State<ListService> {
  var time = DateTime.now();
  final numberFormat =
      NumberFormat.currency(locale: 'es_MX', symbol: '\$', decimalDigits: 0);

  Widget _createInfolabels(String mensaje) {
    return Text(
      mensaje,
      textAlign: TextAlign.center,
      style: const TextStyle(
          fontSize: 21, fontWeight: FontWeight.bold, color: Colors.black),
    );
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
            '${listServices[index].hora}\t\t\t${listServices[index].fecha}',
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
            title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Column(
              children: [
                const Text(
                  "Listado De Servicios",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 19, fontWeight: FontWeight.w700),
                ),
                Text(
                  '${time.day}/${time.month}/${time.year}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                      fontWeight: FontWeight.w600, fontSize: 20),
                ),
              ],
            )
          ],
        )),
        body: Container(child: _createListServiceP(context)),
        floatingActionButton: FloatingActionButton.extended(
          heroTag: 'btnagregar',
          backgroundColor: Colors.green,
          onPressed: () {
            Navigator.push(context,
                MaterialPageRoute(builder: (context) => const GananciaList()));
          },
          icon: const Icon(Icons.playlist_add),
          label: const Text('Ver Ingresos'),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat);
  }
}
