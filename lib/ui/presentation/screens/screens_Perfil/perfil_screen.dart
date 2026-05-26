import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:taxi_servicios/domain/entitis/perfil.dart';
import 'package:taxi_servicios/providers/perfil_provider.dart';
import 'package:taxi_servicios/providers/theme_provider.dart';
import 'package:taxi_servicios/providers/configuracion_provider.dart';
import 'package:taxi_servicios/providers/contadordeservicios_provider.dart';
import 'package:taxi_servicios/ui/presentation/screens/screens_configuracion/listvariables_screen.dart';

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

class PerfilScreen extends StatefulWidget {
  const PerfilScreen({super.key});

  @override
  State<PerfilScreen> createState() => _PerfilScreenState();
}

class _PerfilScreenState extends State<PerfilScreen> {
  final _fmt =
      NumberFormat.currency(locale: 'es_MX', symbol: '\$', decimalDigits: 0);

  @override
  void initState() {
    super.initState();
    // Cargar perfil al abrir la pantalla
    Future.microtask(() => context.read<PerfilProvider>().cargarPerfil());
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
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    _buildHeroPerfil(),
                    _buildStatsRapidas(),
                    const SizedBox(height: 16),
                    _buildSeccion('VEHÍCULO'),
                    _buildCardVehiculo(),
                    const SizedBox(height: 16),
                    _buildSeccion('CONFIGURACIÓN'),
                    _buildCardConfiguracion(),
                    const SizedBox(height: 16),
                    _buildBotonCerrarSesion(),
                    const SizedBox(height: 8),
                    _buildVersion(),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Header ────────────────────────────────────────────────────────────────────

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 16, 14, 0),
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
          const Text(
            'Perfil',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w500,
              color: _C.primary,
            ),
          ),
        ],
      ),
    );
  }

  // ── Hero perfil ───────────────────────────────────────────────────────────────

  Widget _buildHeroPerfil() {
    return Consumer<PerfilProvider>(
      builder: (_, perfilProv, __) {
        final perfil = perfilProv.perfil;

        return Container(
          margin: const EdgeInsets.fromLTRB(12, 14, 12, 0),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [_C.heroBg, Color(0xFF0D2137)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: _C.heroBorder),
          ),
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Avatar con botón editar
              Stack(
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: _C.accent,
                      shape: BoxShape.circle,
                      border: Border.all(
                          color: _C.accent.withOpacity(0.4), width: 2),
                    ),
                    child: Center(
                      child: Text(
                        perfilProv.inicial,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF0F1923),
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: GestureDetector(
                      onTap: () => _mostrarDialogoEditarPerfil(perfil),
                      child: Container(
                        width: 20,
                        height: 20,
                        decoration: BoxDecoration(
                          color: _C.cardBg,
                          shape: BoxShape.circle,
                          border: Border.all(color: _C.heroBorder),
                        ),
                        child: const Icon(
                          Icons.edit_outlined,
                          color: _C.accent,
                          size: 11,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 14),

              // Datos
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      perfil?.nombre.isNotEmpty == true
                          ? perfil!.nombre
                          : 'Agrega tu nombre',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        color: perfil?.nombre.isNotEmpty == true
                            ? _C.primary
                            : _C.muted,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      perfil?.ciudad.isNotEmpty == true
                          ? perfil!.ciudad
                          : 'Agrega tu ciudad',
                      style: TextStyle(
                        fontSize: 10,
                        color: perfil?.ciudad.isNotEmpty == true
                            ? _C.secondary
                            : _C.muted,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        _chip('Conductor', _C.accent),
                        const SizedBox(width: 6),
                        _chip('Activo', _C.green),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _chip(String texto, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withOpacity(0.25)),
      ),
      child: Text(texto, style: TextStyle(fontSize: 9, color: color)),
    );
  }

  // ── Stats rápidas ─────────────────────────────────────────────────────────────

  Widget _buildStatsRapidas() {
    return Consumer2<ContadorServicioProvider, ConfiguracionProvider>(
      builder: (_, contador, config, __) {
        final pct = contador.porcentajeMeta.toStringAsFixed(0);
        return Container(
          margin: const EdgeInsets.fromLTRB(12, 8, 12, 0),
          decoration: BoxDecoration(
            color: _C.cardBg,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: _C.cardBorder),
          ),
          child: Row(
            children: [
              _statItem(
                label: 'Viajes hoy',
                value: '${contador.numeroServiciosTotal}',
                color: _C.accent,
                hasBorder: true,
              ),
              _statItem(
                label: 'Meta diaria',
                value: '\$${_compacto(config.metaRegistradaBD)}',
                color: _C.primary,
                hasBorder: true,
              ),
              _statItem(
                label: 'Cumplimiento',
                value: '$pct%',
                color: contador.porcentajeMeta >= 100 ? _C.green : _C.secondary,
                hasBorder: false,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _statItem({
    required String label,
    required String value,
    required Color color,
    required bool hasBorder,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: hasBorder
            ? const BoxDecoration(
                border: Border(right: BorderSide(color: _C.cardBorder)))
            : null,
        child: Column(
          children: [
            Text(value,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: color,
                )),
            const SizedBox(height: 2),
            Text(label,
                style: const TextStyle(fontSize: 9, color: _C.secondary)),
          ],
        ),
      ),
    );
  }

  String _compacto(int valor) {
    if (valor >= 1000000) return '${(valor / 1000000).toStringAsFixed(1)}M';
    if (valor >= 1000) return '${(valor / 1000).toStringAsFixed(0)}k';
    return valor.toString();
  }

  // ── Sección label ─────────────────────────────────────────────────────────────

  Widget _buildSeccion(String label) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 0, 14, 6),
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

  // ── Card vehículo ─────────────────────────────────────────────────────────────

  Widget _buildCardVehiculo() {
    return Consumer<PerfilProvider>(
      builder: (_, perfilProv, __) {
        final perfil = perfilProv.perfil;
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: _C.cardBg,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: _C.cardBorder),
          ),
          child: Column(
            children: [
              _menuItem(
                icono: Icons.directions_car_outlined,
                label: 'Modelo',
                valor: perfil?.modeloVehiculo.isNotEmpty == true
                    ? perfil!.modeloVehiculo
                    : 'Sin registrar',
                onTap: () => _mostrarDialogoEditarPerfil(perfil),
                esDivider: true,
              ),
              _menuItem(
                icono: Icons.credit_card_outlined,
                label: 'Placa',
                valor: perfil?.placa.isNotEmpty == true
                    ? perfil!.placa.toUpperCase()
                    : 'Sin registrar',
                onTap: () => _mostrarDialogoEditarPerfil(perfil),
                esDivider: false,
              ),
            ],
          ),
        );
      },
    );
  }

  // ── Card configuración ────────────────────────────────────────────────────────

  Widget _buildCardConfiguracion() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: _C.cardBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _C.cardBorder),
      ),
      child: Column(
        children: [
          // Variables de configuración
          _menuItem(
            icono: Icons.tune_rounded,
            label: 'Variables de configuración',
            valor:
                'Meta diaria · ${_fmt.format(context.read<ConfiguracionProvider>().metaRegistradaBD)}',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const Configuration()),
            ),
            esDivider: true,
          ),

          // Toggle modo oscuro
          Consumer<ThemeProvider>(
            builder: (_, themeProv, __) {
              return GestureDetector(
                onTap: () => themeProv.toggleTheme(),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  child: Row(
                    children: [
                      Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: _C.accent.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          themeProv.isDark
                              ? Icons.dark_mode_outlined
                              : Icons.light_mode_outlined,
                          color: _C.accent,
                          size: 16,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Modo oscuro',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: _C.primary,
                              ),
                            ),
                            Text(
                              themeProv.isDark ? 'Activado' : 'Desactivado',
                              style: const TextStyle(
                                  fontSize: 10, color: _C.secondary),
                            ),
                          ],
                        ),
                      ),
                      // Toggle switch
                      GestureDetector(
                        onTap: () => themeProv.toggleTheme(),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          width: 40,
                          height: 22,
                          decoration: BoxDecoration(
                            color: themeProv.isDark
                                ? _C.accent
                                : Colors.grey.shade400,
                            borderRadius: BorderRadius.circular(11),
                          ),
                          child: AnimatedAlign(
                            duration: const Duration(milliseconds: 200),
                            alignment: themeProv.isDark
                                ? Alignment.centerRight
                                : Alignment.centerLeft,
                            child: Container(
                              margin: const EdgeInsets.all(3),
                              width: 16,
                              height: 16,
                              decoration: const BoxDecoration(
                                color: Color(0xFF0F1923),
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  // ── Menu item ─────────────────────────────────────────────────────────────────

  Widget _menuItem({
    required IconData icono,
    required String label,
    required String valor,
    required VoidCallback onTap,
    required bool esDivider,
  }) {
    return Column(
      children: [
        GestureDetector(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            child: Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: _C.accent.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icono, color: _C.accent, size: 16),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        label,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: _C.primary,
                        ),
                      ),
                      Text(
                        valor,
                        style:
                            const TextStyle(fontSize: 10, color: _C.secondary),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right, color: _C.muted, size: 16),
              ],
            ),
          ),
        ),
        if (esDivider)
          const Divider(
              height: 1, color: _C.cardBorder, indent: 14, endIndent: 14),
      ],
    );
  }

  // ── Cerrar sesión ─────────────────────────────────────────────────────────────

  Widget _buildBotonCerrarSesion() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: _C.red.withOpacity(0.06),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _C.red.withOpacity(0.15)),
      ),
      child: GestureDetector(
        onTap: () {
          // TODO: implementar logout cuando se agregue Firebase Auth
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: _C.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child:
                    const Icon(Icons.logout_rounded, color: _C.red, size: 16),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'Cerrar sesión',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: _C.red,
                  ),
                ),
              ),
              const Icon(Icons.chevron_right, color: _C.red, size: 16),
            ],
          ),
        ),
      ),
    );
  }

  // ── Versión ───────────────────────────────────────────────────────────────────

  Widget _buildVersion() {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Text(
        'Versión 1.0.0 · TaxiApp',
        textAlign: TextAlign.center,
        style: TextStyle(fontSize: 10, color: _C.muted),
      ),
    );
  }

  // ── Diálogo editar perfil ─────────────────────────────────────────────────────

  void _mostrarDialogoEditarPerfil(Perfil? perfilActual) {
    final ctrlNombre = TextEditingController(text: perfilActual?.nombre ?? '');
    final ctrlCiudad = TextEditingController(text: perfilActual?.ciudad ?? '');
    final ctrlModelo =
        TextEditingController(text: perfilActual?.modeloVehiculo ?? '');
    final ctrlPlaca = TextEditingController(text: perfilActual?.placa ?? '');

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: _C.cardBg,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Padding(
        padding: EdgeInsets.fromLTRB(
          16,
          16,
          16,
          MediaQuery.of(ctx).viewInsets.bottom + 16,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Handle
            Center(
              child: Container(
                width: 36,
                height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: _C.muted,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const Text(
              'Editar perfil',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: _C.primary,
              ),
            ),
            const SizedBox(height: 16),
            _campoPerfil(ctrl: ctrlNombre, label: 'Nombre', hint: 'Tu nombre'),
            const SizedBox(height: 8),
            _campoPerfil(ctrl: ctrlCiudad, label: 'Ciudad', hint: 'Tu ciudad'),
            const SizedBox(height: 8),
            _campoPerfil(
                ctrl: ctrlModelo,
                label: 'Modelo del vehículo',
                hint: 'Ej: Toyota Corolla 2019'),
            const SizedBox(height: 8),
            _campoPerfil(
                ctrl: ctrlPlaca,
                label: 'Placa',
                hint: 'Ej: ABC 123',
                capitalizacion: TextCapitalization.characters),
            const SizedBox(height: 16),
            GestureDetector(
              onTap: () async {
                final nuevoPerfil = Perfil(
                  nombre: ctrlNombre.text.trim(),
                  ciudad: ctrlCiudad.text.trim(),
                  modeloVehiculo: ctrlModelo.text.trim(),
                  placa: ctrlPlaca.text.trim(),
                );
                await context.read<PerfilProvider>().guardarPerfil(nuevoPerfil);
                if (mounted) Navigator.pop(ctx);
              },
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 13),
                decoration: BoxDecoration(
                  color: _C.accent,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Center(
                  child: Text(
                    'Guardar cambios',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF0F1923),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _campoPerfil({
    required TextEditingController ctrl,
    required String label,
    required String hint,
    TextCapitalization capitalizacion = TextCapitalization.sentences,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 10, color: _C.secondary)),
        const SizedBox(height: 4),
        Container(
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.04),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: _C.cardBorder),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          child: TextField(
            controller: ctrl,
            textCapitalization: capitalizacion,
            style: const TextStyle(color: _C.primary, fontSize: 13),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: const TextStyle(color: _C.muted, fontSize: 11),
              border: InputBorder.none,
              isDense: true,
            ),
          ),
        ),
      ],
    );
  }
}
