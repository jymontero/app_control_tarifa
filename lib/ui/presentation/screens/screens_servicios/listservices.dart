//import 'package:cloud_firestore/cloud_firestore.dart';
// ignore_for_file: unused_element

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:taxi_servicios/providers/contadorservicio_provider.dart';

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

  Widget _createListService(int monto, String fecha) {
    return ListView.builder(
      itemCount: 15,
      itemBuilder: (BuildContext context, int index) {
        return ListTile(
            leading: const Icon(
              Icons.money_off,
              size: 5,
              color: Colors.green,
            ),
            title: Text(
              'COP ${numberFormat.format(monto)}',
              style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black),
            ),
            subtitle: Text(
              fecha,
              style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.normal,
                  color: Colors.black),
            ));
      },
    );
  }

  Widget _createListServiceP(BuildContext context) {
    final listServices = context
        .watch<ContadorServicioProvider>()
        .listaServicios
        .reversed
        .toList();
    return ListView.builder(
      itemCount: listServices.length,
      itemBuilder: (BuildContext context, int index) {
        return ListTile(
          leading: const Icon(
            Icons.local_taxi_rounded,
            size: 25,
            color: Colors.green,
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
                ),
                Text(
                  '${time.day}/${time.month}/${time.year}',
                  textAlign: TextAlign.center,
                ),
              ],
            )
          ],
        )),
        body: _createListServiceP(context));
  }
}
