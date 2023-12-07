// ignore_for_file: no_leading_underscores_for_local_identifiers, duplicate_ignore, avoid_print, prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:taxi_servicios/domain/entitis/servicio.dart';
import 'package:taxi_servicios/domain/entitis/variables.dart';
import 'package:taxi_servicios/providers/configuracion_provider.dart';
import 'package:taxi_servicios/providers/contadordeservicios_provider.dart';
import 'package:taxi_servicios/services/bd_confi.dart';
import 'package:taxi_servicios/ui/presentation/screens/screens_servicios/registryservice_screen.dart';
import 'package:taxi_servicios/ui/presentation/screens/screens_configuracion/listvariables_screen.dart';
import 'package:taxi_servicios/ui/presentation/widgets/app_bar.dart';

import 'screens_tanqueo/gas_screen.dart';
import 'screens_servicios/goaltaxes_screen.dart';
import 'screens_servicios/listservices_screen.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _Home createState() => _Home();
}

class _Home extends State<Home> {
  FireStoreDataBase db = FireStoreDataBase();
  int _paginaActual = 0;

  final List<Widget> _pages = [
    const GoalDairy(),
    const ListService(),
    const Gasoline(),
    const Configuration(),
  ];

  @override
  void initState() {
    print('SE INICILIAO CARGANDO DATA DESDE BD');
    getDataVariableConfig();
    getDataServiciosToday();

    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  void getDataVariableConfig() async {
    List<Variable> listaVaraibles = await db.getModeloVariables();
    Future.microtask(() =>
        context.read<ConfiguracionProvider>().sumarListaBd(listaVaraibles));

    Future.microtask(() => context
        .read<ContadorServicioProvider>()
        .setMetaHacer(context.read<ConfiguracionProvider>().metaRegistradaBD));
  }

  void getDataServiciosToday() async {
    DateTime today = DateTime.now().toLocal();
    final fechaTemp = '${today.day}-${today.month}-${today.year}'.toString();
    List<Servicio> listaServicio = await db.getModeloServicios(fechaTemp);
    if (listaServicio.isNotEmpty) {
      Future.microtask(() => context
          .read<ContadorServicioProvider>()
          .sumarListaServiciosBD(listaServicio, 'HOME'));
    }
  }

  @override
  Widget build(BuildContext context) {
    // ignore: no_leading_underscores_for_local_identifiers
    print('SE CONSTRUYO EN EL BUILDER');

    return WillPopScope(
        onWillPop: () async {
          final shouldPop = await showDialog<bool>(
            context: context,
            builder: (context) {
              return AlertDialog(
                title: const Text(
                  'Salir de la APP?',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                actionsAlignment: MainAxisAlignment.spaceBetween,
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context, true);
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
          return shouldPop!;
        },
        child: Scaffold(
          appBar: AppBarCustomized(),
          body: _pages[_paginaActual],
          bottomNavigationBar: BottomNavigationBar(
              onTap: (index) {
                setState(() {
                  _paginaActual = index;
                });
              },
              currentIndex: _paginaActual,
              items: const [
                BottomNavigationBarItem(
                  icon: Icon(Icons.home),
                  label: "Inicio",
                  backgroundColor: Colors.amber,
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.list),
                  label: "Lista Servicios",
                  backgroundColor: Colors.purple,
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.oil_barrel_sharp),
                  label: "Gasolina",
                  backgroundColor: Colors.green,
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.settings),
                  label: "Config",
                  backgroundColor: Colors.black,
                ),
              ]),
          floatingActionButton: FloatingActionButton(
            heroTag: 'btnaddService',
            backgroundColor: Colors.amber.shade600,
            onPressed: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => const ServiceTaxi()));
            },
            child: const Icon(Icons.add),
          ),
          floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
        ));
  }
}
