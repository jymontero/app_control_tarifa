//import 'package:cloud_firestore/cloud_firestore.dart';
// ignore_for_file: unused_element

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:taxi_servicios/providers/contadorservicio_provider.dart';

class ListService extends StatefulWidget {
  const ListService({super.key});

  @override
  State<ListService> createState() => _ListServiceState();
}

class _ListServiceState extends State<ListService> {
  var time = DateTime.now();

  Widget _createInfolabels(String mensaje) {
    return Text(
      mensaje,
      textAlign: TextAlign.center,
      style: const TextStyle(
          fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black),
    );
  }

  Widget _createListService(int monto, String fecha) {
    return ListView.builder(
      itemCount: 15,
      itemBuilder: (BuildContext context, int index) {
        return ListTile(
            leading: const Icon(
              Icons.money_off,
              size: 30,
              color: Colors.green,
            ),
            title: Text(
              'COP $monto',
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
              Icons.money_off,
              size: 30,
              color: Colors.green,
            ),
            title: Text(
              'COP ${listServices[index].valorservicio}',
              style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black),
            ),
            subtitle: Text(
              '${listServices[index].hora}\t\t\t\t${listServices[index].fecha}',
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
            title: _createInfolabels(
                "Listado De Servicios \n${time.day}/${time.month}/${time.year}")),
        body: _createListServiceP(context));
  }
}


/*Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _createInfolabels(
                "Listado De Servicios \n${time.day}/${time.month}/${time.year}"),
          ],
        ),

        */