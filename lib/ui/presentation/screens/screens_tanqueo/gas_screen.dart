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
    super.initState();
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

  Widget _createFutureBuilderCARD() {
    return FutureBuilder(
        future: bd.getMejorEDS(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Text("AlgoMaloPaso");
          }
          if (snapshot.hasData) {
            listaEDS = snapshot.data!;

            return _createCard();
          }

          return const Center(child: CircularProgressIndicator());
        });
  }

  void _showBottonSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          padding: const EdgeInsets.all(16.0),
          height: 300.0,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Detalles',
                style: TextStyle(
                  fontSize: 24.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16.0),
              const Text(
                'Aquí puedes agregar más información o cualquier contenido que desees mostrar en la ventana emergente.',
              ),
              const SizedBox(height: 16.0),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text('Cerrar'),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _crearListaEdsBD(BuildContext context) {
    if (listaTanqueo.isEmpty) {
      return const Text(
        'No hay EDS Registrados ',
        textAlign: TextAlign.center,
      );
    } else {
      return InkWell(
          onTap: () => _showBottonSheet(context),
          child: ListView.builder(
            padding:
                const EdgeInsets.only(left: 5, top: 0, right: 0, bottom: 70),
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            itemCount: listaTanqueo.length,
            itemBuilder: (BuildContext context, int index) {
              return Card(
                child: Column(
                  children: <Widget>[
                    ListTile(
                      leading: const Icon(
                        Icons.local_gas_station_rounded,
                        size: 25,
                        color: Color.fromARGB(255, 244, 67, 54),
                      ),
                      title: Text(
                        '${listaTanqueo[index].fecha} \t\t\t ${listaTanqueo[index].kilometraje} Km',
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
                    )
                  ],
                ),
              );
            },
          ));
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
                listaEDS.first.nombre.toUpperCase(),
                style: const TextStyle(
                    color: Colors.white, fontWeight: FontWeight.bold),
              ),
              subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text('Barrio ${listaEDS.first.barrio}',
                        style: const TextStyle(
                            color: Colors.white, fontWeight: FontWeight.bold))
                  ]),
              trailing: Text(
                'COP  ${numberFormat.format(listaEDS.first.valorgalon)}',
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
                        child: _createFutureBuilderCARD(),
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
