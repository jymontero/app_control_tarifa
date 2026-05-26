// ignore_for_file: no_leading_underscores_for_local_identifiers, duplicate_ignore, avoid_print, prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:taxi_servicios/domain/entitis/servicio.dart';
import 'package:taxi_servicios/domain/entitis/variables.dart';
import 'package:taxi_servicios/providers/configuracion_provider.dart';
import 'package:taxi_servicios/providers/contadordeservicios_provider.dart';
import 'package:taxi_servicios/providers/theme_provider.dart';
import 'package:taxi_servicios/services/bd_confi.dart';
import 'package:taxi_servicios/ui/presentation/screens/screens_ganancias/homeganancia_screen.dart';
import 'package:taxi_servicios/ui/presentation/screens/screens_servicios/registroservicio_screen.dart';
import 'package:taxi_servicios/ui/presentation/screens/screens_configuracion/listvariables_screen.dart';
import 'package:taxi_servicios/ui/presentation/widgets/app_bar.dart';

import 'screens_tanqueo/gas_screen.dart';
import 'screens_servicios/goaltaxes_screen.dart';

// ── Paleta Dark Premium ───────────────────────────────────────────────────────
class _C {
  static const bg = Color(0xFF0F1923);
  static const navBg = Color(0xFF0D1620);
  static const cardBorder = Color(0xFF1E2D3D);
  static const accent = Color(0xFFF5C518);
  static const primary = Color(0xFFF1F5F9);
  static const muted = Color(0xFF2A3D52);
}

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  _Home createState() => _Home();
}

class _Home extends State<Home> {
  final FireStoreDataBase _db = FireStoreDataBase();
  int _paginaActual = 0;

  final List<Widget> _pages = [
    const GoalDairy(),
    const HomeGanancia(),
    const Gasoline(),
    const Configuration(),
  ];

  // ── Lifecycle ────────────────────────────────────────────────────────────────

  @override
  void initState() {
    super.initState();
    _inicializarDatos();
  }

  @override
  void dispose() {
    super.dispose();
  }

  // ── Inicialización secuencial ─────────────────────────────────────────────────

  Future<void> _inicializarDatos() async {
    // PASO 1 — Cargar variables de configuración
    final List<Variable> listaVariables = await _db.getModeloVariables();
    if (!mounted) return;

    // PASO 2 — Setear variables en ConfiguracionProvider
    context.read<ConfiguracionProvider>().sumarListaBd(listaVariables);

    // PASO 3 — metaRegistradaBD ya tiene el valor correcto
    final int meta = context.read<ConfiguracionProvider>().metaRegistradaBD;
    context.read<ContadorServicioProvider>().setMetaHacer(meta);

    // PASO 4 — Cargar servicios del día
    final DateTime today = DateTime.now().toLocal();
    final String fecha = '${today.day}-${today.month}-${today.year}';
    final List<Servicio> listaServicios = await _db.getModeloServicios(fecha);
    if (!mounted) return;

    // PASO 5 — Sumar servicios contra meta ya inicializada
    if (listaServicios.isNotEmpty) {
      context
          .read<ContadorServicioProvider>()
          .sumarListaServiciosBD(listaServicios, 'HOME');
    }
  }

  // ── Build ─────────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final isDark = context.watch<ThemeProvider>().isDark;

    return PopScope(
      canPop: false,
      onPopInvoked: (bool didPop) async {
        if (didPop) return;
        final bool? salir = await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            backgroundColor: const Color(0xFF1A2535),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: const BorderSide(color: _C.cardBorder),
            ),
            title: const Text(
              '¿Salir de la app?',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: _C.primary,
                fontSize: 15,
                fontWeight: FontWeight.w500,
              ),
            ),
            actionsAlignment: MainAxisAlignment.spaceEvenly,
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(true),
                child: const Text('Sí', style: TextStyle(color: _C.accent)),
              ),
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(false),
                child: const Text('No',
                    style: TextStyle(color: Color(0xFF94A3B8))),
              ),
            ],
          ),
        );
        if (salir == true) SystemNavigator.pop();
      },
      child: Scaffold(
        backgroundColor: isDark ? _C.bg : null,
        appBar: AppBarCustomized(),

        body: _pages[_paginaActual],

        // ── BottomNavigationBar Dark Premium ──────────────────────────────────
        bottomNavigationBar: Container(
          decoration: BoxDecoration(
            border: Border(
              top: BorderSide(
                color: isDark ? _C.cardBorder : Colors.grey.shade200,
              ),
            ),
          ),
          child: BottomNavigationBar(
            onTap: (index) => setState(() => _paginaActual = index),
            currentIndex: _paginaActual,
            backgroundColor: isDark ? _C.navBg : Colors.white,
            selectedItemColor: _C.accent,
            unselectedItemColor: isDark ? _C.muted : Colors.grey.shade400,
            selectedFontSize: 10,
            unselectedFontSize: 9,
            type: BottomNavigationBarType.fixed,
            elevation: 0,
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.home_outlined),
                activeIcon: Icon(Icons.home),
                label: 'Inicio',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.monetization_on_outlined),
                activeIcon: Icon(Icons.monetization_on),
                label: 'Ingresos',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.local_gas_station_outlined),
                activeIcon: Icon(Icons.local_gas_station),
                label: 'Combustible',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.bar_chart_outlined),
                activeIcon: Icon(Icons.bar_chart),
                label: 'Reportes',
              ),
            ],
          ),
        ),

        // ── FAB — solo visible en tabs distintos al Inicio ────────────────────
        floatingActionButton: (_paginaActual == 0)
            ? null
            : FloatingActionButton(
                heroTag: 'btnaddService',
                backgroundColor: _C.accent,
                onPressed: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const RegistroServicio()),
                  );
                },
                child: const Icon(
                  Icons.playlist_add_sharp,
                  color: Color(0xFF0F1923),
                ),
              ),
        floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      ),
    );
  }
}
