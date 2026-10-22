import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:taxi_servicios/domain/entitis/plantilla_item.dart';
import 'package:taxi_servicios/services/bd_confi.dart';

// ── Paleta Dark Premium ───────────────────────────────────────────────────────
class _C {
  static const bg = Color(0xFF0F1923);
  static const cardBg = Color(0xFF1A2535);
  static const cardBorder = Color(0xFF1E2D3D);
  static const accent = Color(0xFFF5C518);
  static const primary = Color(0xFFF1F5F9);
  static const secondary = Color(0xFF94A3B8);
  static const muted = Color(0xFF3D5166);
  static const green = Color(0xFF4ADE80);
  static const red = Color(0xFFF87171);
}

class PlantillaPresupuestoScreen extends StatefulWidget {
  const PlantillaPresupuestoScreen({super.key});

  @override
  State<PlantillaPresupuestoScreen> createState() =>
      _PlantillaPresupuestoScreenState();
}

class _PlantillaPresupuestoScreenState
    extends State<PlantillaPresupuestoScreen> {
  final FireStoreDataBase _bd = FireStoreDataBase();
  List<PlantillaItem> _items = [];
  bool _cargando = true;

  final _fmt =
      NumberFormat.currency(locale: 'es_MX', symbol: '\$', decimalDigits: 0);

  @override
  void initState() {
    super.initState();
    _cargarPlantilla();
  }

  // ── Data ─────────────────────────────────────────────────────────────────────

  Future<void> _cargarPlantilla() async {
    setState(() => _cargando = true);
    final items = await _bd.getPlantilla();
    if (!mounted) return;
    setState(() {
      _items = items;
      _cargando = false;
    });
  }

  // ── Agregar ítem ──────────────────────────────────────────────────────────────

  Future<void> _agregarItem() async {
    final ctrlNombre = TextEditingController();
    final ctrlPlan = TextEditingController();

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: _C.cardBg,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Padding(
        padding: EdgeInsets.fromLTRB(
            16, 16, 16, MediaQuery.of(ctx).viewInsets.bottom + 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 36,
                height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                    color: _C.muted, borderRadius: BorderRadius.circular(2)),
              ),
            ),
            const Text('Nuevo ítem',
                style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: _C.primary)),
            const SizedBox(height: 14),
            // Nombre
            const Text('Nombre del gasto',
                style: TextStyle(fontSize: 10, color: _C.secondary)),
            const SizedBox(height: 6),
            _campoTexto(ctrlNombre, 'Ej: Arriendo, Agua, Internet...'),
            const SizedBox(height: 12),
            // Valor plan
            const Text('Valor planificado',
                style: TextStyle(fontSize: 10, color: _C.secondary)),
            const SizedBox(height: 6),
            _campoNumero(ctrlPlan, 'Valor mensual'),
            const SizedBox(height: 16),
            GestureDetector(
              onTap: () async {
                final nombre = ctrlNombre.text.trim();
                final plan = int.tryParse(ctrlPlan.text) ?? 0;
                if (nombre.isEmpty || plan <= 0) return;
                await _bd.addPlantillaItem(nombre, plan, _items.length + 1);
                if (mounted) {
                  Navigator.pop(ctx);
                  _cargarPlantilla();
                }
              },
              child: _botonPrincipal('Agregar'),
            ),
          ],
        ),
      ),
    );
  }

  // ── Editar ítem ───────────────────────────────────────────────────────────────

  Future<void> _editarItem(PlantillaItem item) async {
    final ctrlNombre = TextEditingController(text: item.nombre);
    final ctrlPlan = TextEditingController(text: item.planBase.toString());

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: _C.cardBg,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Padding(
        padding: EdgeInsets.fromLTRB(
            16, 16, 16, MediaQuery.of(ctx).viewInsets.bottom + 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 36,
                height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                    color: _C.muted, borderRadius: BorderRadius.circular(2)),
              ),
            ),
            Text(item.nombre,
                style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: _C.primary)),
            const SizedBox(height: 14),
            const Text('Valor planificado base',
                style: TextStyle(fontSize: 10, color: _C.secondary)),
            const SizedBox(height: 6),
            _campoNumero(ctrlPlan, 'Valor mensual'),
            const SizedBox(height: 16),
            GestureDetector(
              onTap: () async {
                final plan = int.tryParse(ctrlPlan.text) ?? 0;
                if (plan <= 0) return;
                await _bd.updatePlantillaItem(item.id, plan);
                if (mounted) {
                  Navigator.pop(ctx);
                  _cargarPlantilla();
                }
              },
              child: _botonPrincipal('Guardar cambio'),
            ),
            const SizedBox(height: 8),
            // Eliminar
            GestureDetector(
              onTap: () async {
                final confirmar = await showDialog<bool>(
                  context: ctx,
                  builder: (dCtx) => AlertDialog(
                    backgroundColor: _C.cardBg,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                      side: const BorderSide(color: _C.cardBorder),
                    ),
                    title: const Text('¿Eliminar ítem?',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            color: _C.primary,
                            fontSize: 15,
                            fontWeight: FontWeight.w500)),
                    content: Text(
                      'Se eliminará "${item.nombre}" de la plantilla.',
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: _C.secondary, fontSize: 12),
                    ),
                    actionsAlignment: MainAxisAlignment.spaceEvenly,
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(dCtx, true),
                        child: const Text('Eliminar',
                            style: TextStyle(color: _C.red)),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pop(dCtx, false),
                        child: const Text('Cancelar',
                            style: TextStyle(color: _C.secondary)),
                      ),
                    ],
                  ),
                );
                if (confirmar == true && mounted) {
                  await _bd.deletePlantillaItem(item.id);
                  Navigator.pop(ctx);
                  _cargarPlantilla();
                }
              },
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 11),
                decoration: BoxDecoration(
                  color: _C.red.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: _C.red.withOpacity(0.2)),
                ),
                child: const Center(
                  child: Text('Eliminar ítem',
                      style: TextStyle(
                          fontSize: 12,
                          color: _C.red,
                          fontWeight: FontWeight.w500)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Build ─────────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                  : _items.isEmpty
                      ? _buildVacio()
                      : _buildLista(),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _agregarItem,
        backgroundColor: _C.accent,
        child: const Icon(Icons.add, color: Color(0xFF0F1923)),
      ),
    );
  }

  // ── Header ────────────────────────────────────────────────────────────────────

  Widget _buildHeader() {
    return Container(
      color: const Color(0xFF0D1F2D),
      padding: const EdgeInsets.fromLTRB(14, 16, 14, 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
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
                  child: const Icon(Icons.arrow_back_ios_new_rounded,
                      color: _C.secondary, size: 14),
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Plantilla de presupuesto',
                        style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: _C.primary)),
                    Text('Ítems base para todos los meses',
                        style: TextStyle(fontSize: 10, color: _C.secondary)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Aviso
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: _C.accent.withOpacity(0.06),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: _C.accent.withOpacity(0.15)),
            ),
            child: const Row(
              children: [
                Icon(Icons.info_outline_rounded, color: _C.accent, size: 14),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Los cambios aquí aplican a los meses futuros. '
                    'Para cambiar solo el mes actual usa la pantalla de Presupuesto.',
                    style: TextStyle(fontSize: 10, color: _C.accent),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Lista ─────────────────────────────────────────────────────────────────────

  Widget _buildLista() {
    final totalBase = _items.fold(0, (s, i) => s + i.planBase);
    return ListView(
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 80),
      children: [
        // Total base
        Container(
          margin: const EdgeInsets.only(bottom: 10),
          decoration: BoxDecoration(
            color: _C.cardBg,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: _C.cardBorder),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Total base mensual',
                  style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: _C.primary)),
              Text(_fmt.format(totalBase),
                  style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: _C.accent)),
            ],
          ),
        ),
        // Items
        Container(
          decoration: BoxDecoration(
            color: _C.cardBg,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: _C.cardBorder),
          ),
          child: Column(
            children: _items.asMap().entries.map((entry) {
              final i = entry.key;
              final item = entry.value;
              return Column(
                children: [
                  GestureDetector(
                    onTap: () => _editarItem(item),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 12),
                      child: Row(
                        children: [
                          // Número orden
                          Container(
                            width: 24,
                            height: 24,
                            decoration: BoxDecoration(
                              color: _C.accent.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Center(
                              child: Text('${i + 1}',
                                  style: const TextStyle(
                                      fontSize: 10,
                                      color: _C.accent,
                                      fontWeight: FontWeight.w500)),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(item.nombre,
                                style: const TextStyle(
                                    fontSize: 11, color: _C.primary)),
                          ),
                          Text(_fmt.format(item.planBase),
                              style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w500,
                                  color: _C.secondary)),
                          const SizedBox(width: 8),
                          const Icon(Icons.chevron_right,
                              color: _C.muted, size: 16),
                        ],
                      ),
                    ),
                  ),
                  if (i < _items.length - 1)
                    const Divider(color: _C.cardBorder, height: 1, indent: 48),
                ],
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  // ── Vacío ─────────────────────────────────────────────────────────────────────

  Widget _buildVacio() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.playlist_add_rounded, color: _C.muted, size: 48),
          const SizedBox(height: 12),
          const Text('Sin ítems en la plantilla',
              style: TextStyle(color: _C.secondary, fontSize: 13)),
          const SizedBox(height: 4),
          const Text('Toca + para agregar tus gastos fijos',
              style: TextStyle(color: _C.muted, fontSize: 11)),
        ],
      ),
    );
  }

  // ── Helpers UI ────────────────────────────────────────────────────────────────

  Widget _campoTexto(TextEditingController ctrl, String hint) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.04),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: _C.cardBorder),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: TextField(
        controller: ctrl,
        style: const TextStyle(color: _C.primary, fontSize: 13),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(color: _C.muted, fontSize: 11),
          border: InputBorder.none,
          isDense: true,
        ),
      ),
    );
  }

  Widget _campoNumero(TextEditingController ctrl, String hint) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.04),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: _C.accent.withOpacity(0.3)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: TextField(
        controller: ctrl,
        keyboardType: TextInputType.number,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        style: const TextStyle(color: _C.primary, fontSize: 13),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(color: _C.muted, fontSize: 11),
          border: InputBorder.none,
          isDense: true,
          prefixText: '\$ ',
          prefixStyle: const TextStyle(color: _C.accent, fontSize: 13),
        ),
      ),
    );
  }

  Widget _botonPrincipal(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 13),
      decoration: BoxDecoration(
        color: _C.accent,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Center(
        child: Text(label,
            style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: Color(0xFF0F1923))),
      ),
    );
  }
}
