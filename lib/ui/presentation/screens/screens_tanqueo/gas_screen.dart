import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:taxi_servicios/domain/entitis/estaciongas.dart';
import 'package:taxi_servicios/domain/entitis/gas.dart';
import 'package:taxi_servicios/services/bd_confi.dart';
import 'package:taxi_servicios/ui/presentation/screens/screens_EDS/listadoeds_screen.dart';

class Gasoline extends StatefulWidget {
  const Gasoline({super.key});

  @override
  State<Gasoline> createState() => _GasolineState();
}

class _GasolineState extends State<Gasoline> {
  FireStoreDataBase bd = FireStoreDataBase();
  late List<GasolineTank> listaTanqueo = [];
  late List<EstacionGas> listaEDS = [];
  final numberFormat =
      NumberFormat.currency(locale: 'es_MX', symbol: '\$', decimalDigits: 0);

  @override
  void initState() {
    getMejorEDS();
    super.initState();
  }

  void getMejorEDS() async {
    listaEDS = await bd.getModeloEDS();
    print(listaEDS.first.valorgalon);
  }

  Widget _createFutureBuilderGAS() {
    return SingleChildScrollView(
        child: FutureBuilder(
            future: bd.getModeloTanqueo(),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return const Text("AlgoMaloPaso");
              }
              if (snapshot.hasData) {
                listaTanqueo = snapshot.data!;

                return _crearListaEdsBD(context);
              }

              return const Center(child: CircularProgressIndicator());
            }));
  }

  Widget _crearListaEdsBD(BuildContext context) {
    if (listaTanqueo.isEmpty) {
      return const Text(
        'No hay EDS Registrados ',
        textAlign: TextAlign.center,
      );
    } else {
      return ListView.builder(
        padding: const EdgeInsets.only(left: 5, top: 0, right: 0, bottom: 70),
        physics: const NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        itemCount: listaTanqueo.length,
        itemBuilder: (BuildContext context, int index) {
          return ListTile(
            leading: const Icon(
              Icons.local_gas_station_rounded,
              size: 25,
              color: Colors.black,
            ),
            title: Text(
              '${listaTanqueo[index].kilometraje} Km \t\t\t${listaTanqueo[index].galon} Gal',
              style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.normal,
                  color: Colors.black),
            ),
            subtitle: Text(
              'COP ${numberFormat.format(listaTanqueo[index].valor)}',
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
                                      bd.eliminarEDS(listaTanqueo[index].id);

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

  Widget _createCard() {
    return Card(
        elevation: 4.0,
        color: Colors.lightBlue[900],
        child: Column(
          children: [
            const SizedBox(
              height: 20,
            ),
            SizedBox(
              height: 110.0,
              child: Ink.image(
                image: const AssetImage("assets/images/primax.jpg"),
                fit: BoxFit.fill,
              ),
            ),
            ListTile(
              title: Text(
                '000',
                //listaEDS.first.nombre.toUpperCase(),
                style: const TextStyle(
                    color: Colors.white, fontWeight: FontWeight.bold),
              ),
              subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text('Barrio ' /*${listaEDS.first.barrio}*/,
                        style: const TextStyle(
                            color: Colors.white, fontWeight: FontWeight.bold))
                  ]),
              trailing: Text(
                'COP ' /*${numberFormat.format(listaEDS.first.valorgalon)}'*/,
                style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white),
              ),
            ),
          ],
        ));
  }

  @override
  Widget build(BuildContext context) {
    if (listaEDS.isEmpty) {
      print('ListaVacia');
      getMejorEDS();
    }
    return Scaffold(
        body: LayoutBuilder(
          builder: (BuildContext context, BoxConstraints viewportConstraints) {
            return SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: viewportConstraints.maxHeight,
                ),
                child: IntrinsicHeight(
                  child: Column(
                    children: <Widget>[
                      Container(
                        // A fixed-height child.
                        color: const Color(0xffd6d6cd), // Yellow
                        height: 210.0,
                        alignment: Alignment.center,
                        child: _createCard(),
                      ),
                      Expanded(
                        // A flexible child that will grow to fit the viewport but
                        // still be at least as big as necessary to fit its contents.
                        child: Container(
                          color: const Color(0xffd6d6cd),
                          height: 120.0,
                          alignment: Alignment.center,
                          child: _createFutureBuilderGAS(),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
        floatingActionButton: FloatingActionButton.extended(
          heroTag: 'btnEDS',
          backgroundColor: Colors.orange,
          onPressed: () {
            Navigator.push(context,
                MaterialPageRoute(builder: (context) => const ListEDS()));
          },
          // ignore: unnecessary_const
          icon: const Icon(Icons.playlist_add),
          label: const Text('Agregar EDS'),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat);
  }
}
