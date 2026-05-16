import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:taxi_servicios/domain/entitis/estaciongas.dart';
import 'package:taxi_servicios/services/bd_confi.dart';
import 'package:taxi_servicios/ui/presentation/screens/screens_EDS/editeds_screen.dart';
import 'package:taxi_servicios/ui/presentation/screens/screens_EDS/registryeds_screen.dart';
import 'package:taxi_servicios/ui/presentation/widgets/app_bar.dart';

// ── Paleta Dark Premium ───────────────────────────────────────────────────────
class _C {
  static const bg = Color(0xFF0F1923);
  static const cardBg = Color(0xFF1A2535);
  static const cardBorder = Color(0xFF1E2D3D);
  static const accent = Color(0xFFF5C518);
  static const primary = Color(0xFFF1F5F9);
  static const secondary = Color(0xFF94A3B8);
  static const muted = Color(0xFF3D5166);
  static const red = Color(0xFFF87171);
}

class ListEDS extends StatefulWidget {
  const ListEDS({super.key});

  @override
  State<ListEDS> createState() => _ListEDSState();
}

class _ListEDSState extends State<ListEDS> {
  final FireStoreDataBase _bd = FireStoreDataBase();
  List<EstacionGas> _listaEDS = [];
  bool _cargando = true;

  final _fmt =
      NumberFormat.currency(locale: 'es_MX', symbol: '\$', decimalDigits: 0);

  // ── Lifecycle ────────────────────────────────────────────────────────────────

  @override
  void initState() {
    super.initState();
    _cargarEDS();
  }

  // ── Data ─────────────────────────────────────────────────────────────────────

  Future<void> _cargarEDS() async {
    final lista = await _bd.getModeloEDS();
    if (!mounted) return;
    setState(() {
      _listaEDS = lista;
      _cargando = false;
    });
  }

  Future<void> _eliminarEDS(EstacionGas eds) async {
    final confirmado = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: _C.cardBg,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: _C.cardBorder),
        ),
        title: const Text(
          '¿Eliminar EDS?',
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
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Sí', style: TextStyle(color: _C.red)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('No', style: TextStyle(color: _C.secondary)),
          ),
        ],
      ),
    );

    if (confirmado == true && mounted) {
      await _bd.eliminarEDS(eds.id);
      await _cargarEDS();
    }
  }

  // ── Build ─────────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AppBarCustomized(),
      backgroundColor: _C.bg,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildHeader(),
            Expanded(
              child: _cargando
                  ? const Center(
                      child: CircularProgressIndicator(color: _C.accent))
                  : _listaEDS.isEmpty
                      ? _buildEstadoVacio()
                      : _buildListaEDS(),
            ),
            _buildBotonAgregar(),
            Padding(
                padding: const EdgeInsets.fromLTRB(16, 2, 16, 16),
                child: _buildChipResumen()),
          ],
        ),
      ),
    );
  }

  // ── Header ────────────────────────────────────────────────────────────────────

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 16, 14, 10),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.04),
                borderRadius: BorderRadius.circular(9),
                border: Border.all(color: _C.cardBorder),
              ),
              child: const Icon(
                Icons.arrow_back_ios_new_rounded,
                color: _C.secondary,
                size: 14,
              ),
            ),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Estaciones de servicio',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: _C.primary,
                  ),
                ),
                Text(
                  'Selecciona tu EDS activa',
                  style: TextStyle(fontSize: 10, color: _C.secondary),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Estado vacío ──────────────────────────────────────────────────────────────

  Widget _buildEstadoVacio() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.local_gas_station_outlined, color: _C.muted, size: 48),
          SizedBox(height: 12),
          Text(
            'No hay EDS registradas',
            style: TextStyle(color: _C.secondary, fontSize: 13),
          ),
          SizedBox(height: 4),
          Text(
            'Agrega tu primera estación de servicio',
            style: TextStyle(color: _C.muted, fontSize: 11),
          ),
        ],
      ),
    );
  }

  // ── Lista EDS ─────────────────────────────────────────────────────────────────

  Widget _buildListaEDS() {
    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      itemCount: _listaEDS.length,
      separatorBuilder: (_, __) => const SizedBox(height: 6),
      itemBuilder: (context, index) {
        final eds = _listaEDS[index];
        final isActiva = index == 0; // la primera es la activa (menor precio)
        return _buildEDSItem(eds, isActiva);
      },
    );
  }

  Widget _buildEDSItem(EstacionGas eds, bool isActiva) {
    return Container(
      decoration: BoxDecoration(
        color: _C.cardBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isActiva ? _C.accent.withOpacity(0.35) : _C.cardBorder,
        ),
      ),
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          // Ícono
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: isActiva
                  ? _C.accent.withOpacity(0.1)
                  : Colors.white.withOpacity(0.04),
              borderRadius: BorderRadius.circular(9),
            ),
            child: Icon(
              Icons.local_gas_station_rounded,
              color: isActiva ? _C.accent : _C.secondary,
              size: 18,
            ),
          ),
          const SizedBox(width: 10),

          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      eds.nombre,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: _C.primary,
                      ),
                    ),
                    if (isActiva) ...[
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 1),
                        decoration: BoxDecoration(
                          color: _C.accent.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(5),
                          border: Border.all(color: _C.accent.withOpacity(0.3)),
                        ),
                        child: const Text(
                          'Activa',
                          style: TextStyle(fontSize: 8, color: _C.accent),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  eds.barrio,
                  style: const TextStyle(fontSize: 10, color: _C.secondary),
                ),
              ],
            ),
          ),

          // Precio
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              const Text(
                'Precio galón',
                style: TextStyle(fontSize: 9, color: _C.secondary),
              ),
              Text(
                _fmt.format(eds.valorgalon),
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: isActiva ? _C.accent : _C.primary,
                ),
              ),
            ],
          ),
          const SizedBox(width: 20),

          // Acciones
          Row(
            children: [
              GestureDetector(
                onTap: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => EditEDS(eds)),
                  );
                  _cargarEDS();
                },
                child: Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: _C.accent.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(7),
                  ),
                  child: const Icon(Icons.edit_outlined,
                      color: _C.accent, size: 14),
                ),
              ),
              const SizedBox(width: 5),
              GestureDetector(
                onTap: () => _eliminarEDS(eds),
                child: Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: _C.red.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(7),
                  ),
                  child:
                      const Icon(Icons.delete_outline, color: _C.red, size: 14),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── Botón agregar fijo ────────────────────────────────────────────────────────

  Widget _buildBotonAgregar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
      decoration: const BoxDecoration(
        color: _C.bg,
        border: Border(top: BorderSide(color: _C.cardBorder)),
      ),
      child: GestureDetector(
        onTap: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const RegistryEDS()),
          );
          _cargarEDS();
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 13),
          decoration: BoxDecoration(
            border: Border.all(
              color: _C.accent.withOpacity(0.3),
              style: BorderStyle.solid,
            ),
            borderRadius: BorderRadius.circular(14),
          ),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.add, color: _C.accent, size: 16),
              SizedBox(width: 8),
              Text(
                'Agregar nueva EDS',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: _C.accent,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  // ── Botón agregar fijo ────────────────────────────────────────────────────────

  Widget _buildChipResumen() {
    return Container(
      decoration: BoxDecoration(
        color: _C.accent.withOpacity(0.06),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: _C.accent.withOpacity(0.15),
        ),
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 10,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Icono
          Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              color: _C.accent.withOpacity(0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.local_gas_station_rounded,
              color: _C.accent,
              size: 16,
            ),
          ),

          const SizedBox(width: 10),

          // Texto
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'EDS recomendada',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: _C.primary,
                  ),
                ),
                SizedBox(height: 3),
                Text(
                  'La estación seleccionada cuenta con el mejor precio de gasolina y puede utilizarse como referencia principal para registrar tanqueos.',
                  style: TextStyle(
                    fontSize: 10,
                    height: 1.4,
                    color: _C.secondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
