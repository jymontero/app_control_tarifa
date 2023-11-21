import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:taxi_servicios/domain/entitis/estaciongas.dart';
import 'package:taxi_servicios/services/bd_confi.dart';
import 'package:taxi_servicios/ui/presentation/screens/screens_EDS/registryeds_screen.dart';
import 'package:taxi_servicios/ui/presentation/widgets/app_bar.dart';

class ListEDS extends StatefulWidget {
  const ListEDS({super.key});

  @override
  State<ListEDS> createState() => _ListEDSState();
}

class _ListEDSState extends State<ListEDS> {
  FireStoreDataBase bd = FireStoreDataBase();
  late List<EstacionGas> listaEDS = [];
  final numberFormat =
      NumberFormat.currency(locale: 'es_MX', symbol: '\$', decimalDigits: 0);

  Widget createFutureBuilderEDS() {
    return FutureBuilder(
        future: bd.getModeloEDS(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Text("AlgoMaloPaso");
          }
          if (snapshot.hasData) {
            listaEDS = snapshot.data!;

            return _crearListaEdsBD(context);
          }

          return const Center(child: CircularProgressIndicator());
        });
  }

  Widget _crearListaEdsBD(BuildContext context) {
    if (listaEDS.isEmpty) {
      return const Text(
        'No hay EDS Registrados ',
        textAlign: TextAlign.center,
      );
    } else {
      return ListView.builder(
        padding: const EdgeInsets.only(left: 5, top: 0, right: 0, bottom: 70),
        shrinkWrap: true,
        itemCount: listaEDS.length,
        itemBuilder: (BuildContext context, int index) {
          return ListTile(
            leading: const Icon(
              Icons.local_gas_station_rounded,
              size: 25,
              color: Colors.black,
            ),
            title: Text(
              '${listaEDS[index].nombre}\t\t${listaEDS[index].barrio}',
              style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.normal,
                  color: Colors.black),
            ),
            subtitle: Text(
              'COP ${numberFormat.format(listaEDS[index].valorgalon)}',
              style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
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
                              title: const Text('Desesa Eliminar La EDS'),
                              actionsAlignment: MainAxisAlignment.spaceBetween,
                              actions: [
                                TextButton(
                                    onPressed: () {
                                      bd.eliminarEDS(listaEDS[index].id);

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: const AppBarCustomized(),
        body: SizedBox(child: createFutureBuilderEDS()),
        floatingActionButton: FloatingActionButton.extended(
          backgroundColor: Colors.orange,
          onPressed: () {
            Navigator.push(context,
                MaterialPageRoute(builder: (context) => const RegistryEDS()));
          },
          icon: const Icon(Icons.playlist_add),
          label: const Text('Agregar EDS'),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat);
  }
}
