// ignore_for_file: no_leading_underscores_for_local_identifiers, duplicate_ignore, avoid_print, prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:taxi_servicios/domain/entitis/servicio.dart';
import 'package:taxi_servicios/domain/entitis/variables.dart';
import 'package:taxi_servicios/providers/configuracion_provider.dart';
import 'package:taxi_servicios/providers/contadordeservicios_provider.dart';
import 'package:taxi_servicios/services/bd_confi.dart';
import 'package:taxi_servicios/ui/presentation/screens/screens_servicios/registroservicio_screen.dart';
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
  final FireStoreDataBase db = FireStoreDataBase();
  int _paginaActual = 0;

  final List<Widget> _pages = [
    const GoalDairy(),
    const ListService(),
    const Gasoline(),
    const Configuration(),
  ];

  @override
  void initState() {
    //print('SE INICILIAO CARGANDO DATA DESDE BD');
    //getDataVariableConfig();
    getDataServiciosToday();
    //db.actualizarFormatoFechas();

    super.initState();
    _inicializarDatos();
  }

  @override
  void dispose() {
    super.dispose();
  }
  // ── Inicialización secuencial ───────────────────────────────────────────────
  // FIX: antes eran 2 funciones async en paralelo sin orden garantizado.
  // Ahora es 1 función secuencial que garantiza:
  // 1. Variables cargadas → metaRegistradaBD tiene valor correcto
  // 2. setMetaHacer recibe el valor real → _metaTotalOriginal queda bien
  // 3. Servicios se suman contra la meta ya inicializada

  Future<void> _inicializarDatos() async {
    // PASO 1 — Cargar variables de configuración
    final List<Variable> listaVariables = await db.getModeloVariables();
    if (!mounted) return;

    // PASO 2 — Setear variables en ConfiguracionProvider
    context.read<ConfiguracionProvider>().sumarListaBd(listaVariables);

    // PASO 3 — Ahora metaRegistradaBD tiene el valor correcto
    final int meta = context.read<ConfiguracionProvider>().metaRegistradaBD;
    context.read<ContadorServicioProvider>().setMetaHacer(meta);

    // PASO 4 — Cargar servicios del día
    final DateTime today = DateTime.now().toLocal();
    final String fecha = '${today.day}-${today.month}-${today.year}';
    final List<Servicio> listaServicios = await db.getModeloServicios(fecha);
    if (!mounted) return;

    // PASO 5 — Sumar servicios contra meta ya inicializada
    if (listaServicios.isNotEmpty) {
      context
          .read<ContadorServicioProvider>()
          .sumarListaServiciosBD(listaServicios, 'HOME');
    }
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

    return PopScope(
        canPop: false,
        onPopInvoked: (bool didPop) async {
          if (didPop) return;

          final bool? salir = await showDialog<bool>(
            context: context,
            builder: (context) {
              return AlertDialog(
                title: const Text(
                  '¿Salir de la APP?',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                actionsAlignment: MainAxisAlignment.spaceBetween,
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop(true);
                    },
                    child: const Text('Sí'),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop(false);
                    },
                    child: const Text('No'),
                  ),
                ],
              );
            },
          );

          if (salir == true) {
            SystemNavigator.pop();
          }
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
                  icon: Icon(Icons.monetization_on_outlined),
                  label: "Ingresos",
                  backgroundColor: Colors.purple,
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.local_gas_station_sharp),
                  label: "Consumo",
                  backgroundColor: Colors.green,
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.settings),
                  label: "Mas...",
                  backgroundColor: Colors.black,
                ),
              ]),
          floatingActionButton: (_paginaActual == 0)
              ? null
              : FloatingActionButton(
                  heroTag: 'btnaddService',
                  backgroundColor: Colors.amber.shade600,
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const RegistroServicio()));
                  },
                  child: const Icon(Icons.playlist_add_sharp),
                ),
          floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
        ));
  }
}
