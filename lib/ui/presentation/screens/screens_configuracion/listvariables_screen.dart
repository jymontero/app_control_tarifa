import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:taxi_servicios/domain/entitis/variables.dart';
import 'package:taxi_servicios/providers/configuracion_provider.dart';
import 'package:taxi_servicios/providers/contadordeservicios_provider.dart';
import 'package:taxi_servicios/services/bd_confi.dart';
import 'package:taxi_servicios/ui/presentation/screens/screens_configuracion/editsetup_screen.dart';
import 'package:taxi_servicios/ui/presentation/screens/screens_configuracion/registrysetup_screen.dart';

// ── Paleta Dark Premium ───────────────────────────────────────────────────────
class _C {
  static const bg = Color(0xFF0F1923);
  static const cardBg = Color(0xFF1A2535);
  static const cardBorder = Color(0xFF1E2D3D);
  static const heroBg = Color(0xFF1A3A5C);
  static const heroBorder = Color(0xFF1E3A55);
  static const accent = Color(0xFFF5C518);
  static const primary = Color(0xFFF1F5F9);
  static const secondary = Color(0xFF94A3B8);
  static const muted = Color(0xFF3D5166);
  static const green = Color(0xFF4ADE80);
  static const red = Color(0xFFF87171);
}

class Configuration extends StatefulWidget {
  const Configuration({super.key});

  @override
  State<Configuration> createState() => _ConfigurationState();
}

class _ConfigurationState extends State<Configuration> {
  final FireStoreDataBase _bd = FireStoreDataBase();
  List<Variable> _listaVariables = [];
  bool _cargando = true;

  final _fmt =
      NumberFormat.currency(locale: 'es_MX', symbol: '\$', decimalDigits: 0);

  // ── Lifecycle ────────────────────────────────────────────────────────────────

  @override
  void initState() {
    super.initState();
    _cargarVariables();
  }

  // ── Data ─────────────────────────────────────────────────────────────────────

  Future<void> _cargarVariables() async {
    final lista = await _bd.getModeloVariables();
    if (!mounted) return;
    setState(() {
      _listaVariables = lista;
      _cargando = false;
    });
  }

  Future<void> _eliminarVariable(Variable variable) async {
    final confirmado = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: _C.cardBg,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: _C.cardBorder),
        ),
        title: const Text(
          '¿Eliminar variable?',
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
      context.read<ConfiguracionProvider>().restaVariable(variable.valor);
      context
          .read<ContadorServicioProvider>()
          .decrementarMetaPorHacer(variable.valor);
      await _bd.eliminarVariable(variable.id);
      await _cargarVariables();
    }
  }

  // ── Helpers ──────────────────────────────────────────────────────────────────

  int get _metaTotal => _listaVariables.fold(0, (sum, v) => sum + v.valor);

  // ── Build ─────────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _C.bg,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildTitulo(),
            _buildCardMeta(),
            _buildGrupoHeader('VARIABLES BASE'),
            Expanded(
              child: _cargando
                  ? const Center(
                      child: CircularProgressIndicator(color: _C.accent))
                  : _listaVariables.isEmpty
                      ? _buildEstadoVacio()
                      : _buildListaVariables(),
            ),
            _buildBotonAgregar(),
          ],
        ),
      ),
    );
  }

  // ── Título ────────────────────────────────────────────────────────────────────

  Widget _buildTitulo() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 16, 14, 0),
      child: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: _C.accent.withOpacity(0.1),
              borderRadius: BorderRadius.circular(9),
            ),
            child: const Icon(Icons.tune_rounded, color: _C.accent, size: 16),
          ),
          const SizedBox(width: 10),
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Configuración',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: _C.primary,
                ),
              ),
              Text(
                'Variables para el cálculo de la meta diaria',
                style: TextStyle(fontSize: 10, color: _C.secondary),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── Card meta calculada ───────────────────────────────────────────────────────

  Widget _buildCardMeta() {
    return Consumer<ConfiguracionProvider>(
      builder: (_, config, __) {
        return Container(
          margin: const EdgeInsets.fromLTRB(12, 12, 12, 0),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [_C.heroBg, Color(0xFF0D2137)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: _C.heroBorder),
          ),
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'META DIARIA CALCULADA',
                style: TextStyle(
                  fontSize: 10,
                  color: _C.secondary,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                _fmt.format(config.metaRegistradaBD),
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w500,
                  color: _C.accent,
                ),
              ),
              const SizedBox(height: 8),
              const Divider(color: Color(0xFF1E3A55), height: 1),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Suma de todas las variables activas',
                    style: TextStyle(fontSize: 9, color: _C.secondary),
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: _C.accent.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: _C.accent.withOpacity(0.2)),
                    ),
                    child: Text(
                      '${_listaVariables.length} variables',
                      style: const TextStyle(fontSize: 9, color: _C.accent),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  // ── Header grupo ──────────────────────────────────────────────────────────────

  Widget _buildGrupoHeader(String label) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 6),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 9,
          color: _C.muted,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  // ── Estado vacío ──────────────────────────────────────────────────────────────

  Widget _buildEstadoVacio() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.tune_rounded, color: _C.muted, size: 48),
          SizedBox(height: 12),
          Text(
            'Sin variables configuradas',
            style: TextStyle(color: _C.secondary, fontSize: 13),
          ),
          SizedBox(height: 4),
          Text(
            'Agrega variables para calcular tu meta diaria',
            style: TextStyle(color: _C.muted, fontSize: 11),
          ),
        ],
      ),
    );
  }

  // ── Lista variables ───────────────────────────────────────────────────────────

  Widget _buildListaVariables() {
    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      itemCount: _listaVariables.length,
      separatorBuilder: (_, __) => const SizedBox(height: 6),
      itemBuilder: (context, index) {
        return _buildVariableItem(_listaVariables[index]);
      },
    );
  }

  Widget _buildVariableItem(Variable variable) {
    final tieneValor = variable.valor > 0;

    return Container(
      decoration: BoxDecoration(
        color: _C.cardBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _C.cardBorder),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: Row(
        children: [
          // Ícono
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: tieneValor
                  ? _C.accent.withOpacity(0.1)
                  : Colors.white.withOpacity(0.04),
              borderRadius: BorderRadius.circular(9),
            ),
            child: Icon(
              Icons.tune_rounded,
              color: tieneValor ? _C.accent : _C.muted,
              size: 16,
            ),
          ),
          const SizedBox(width: 10),

          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  variable.nombre,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: _C.primary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  tieneValor
                      ? _fmt.format(variable.valor)
                      : '\$0 — sin valor asignado',
                  style: TextStyle(
                    fontSize: 10,
                    color: tieneValor ? _C.accent : _C.muted,
                    fontWeight:
                        tieneValor ? FontWeight.w500 : FontWeight.normal,
                  ),
                ),
              ],
            ),
          ),

          // Acciones
          GestureDetector(
            onTap: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => EditVariable(variable)),
              );
              _cargarVariables();
            },
            child: Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                color: _C.accent.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child:
                  const Icon(Icons.edit_outlined, color: _C.accent, size: 14),
            ),
          ),
          const SizedBox(width: 6),
          GestureDetector(
            onTap: () => _eliminarVariable(variable),
            child: Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                color: _C.red.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.delete_outline, color: _C.red, size: 14),
            ),
          ),
        ],
      ),
    );
  }

  // ── Botón agregar fijo ────────────────────────────────────────────────────────

  Widget _buildBotonAgregar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 8, 85, 12),
      decoration: const BoxDecoration(
        color: _C.bg,
        border: Border(top: BorderSide(color: _C.cardBorder)),
      ),
      child: GestureDetector(
        onTap: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const RegistryVariable()),
          );
          _cargarVariables();
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 13),
          decoration: BoxDecoration(
            border: Border.all(color: _C.accent.withOpacity(0.3)),
            borderRadius: BorderRadius.circular(14),
          ),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.add, color: _C.accent, size: 16),
              SizedBox(width: 8),
              Text(
                'Agregar variable',
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
}
