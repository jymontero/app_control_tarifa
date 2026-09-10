import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:cron/cron.dart';
import 'package:provider/provider.dart';
import 'package:taxi_servicios/providers/turno_provider.dart';
import 'package:taxi_servicios/ui/presentation/screens/screens_Perfil/perfil_screen.dart';
import 'package:taxi_servicios/ui/presentation/screens/screens_calendarioTurno/turno_screen.dart';
import 'package:taxi_servicios/ui/presentation/screens/screens_finturno/finish_screen.dart';

// ── Paleta Dark Premium ───────────────────────────────────────────────────────
class _C {
  static const accent = Color(0xFFF5C518);
  static const primary = Color(0xFFF1F5F9);
  static const secondary = Color(0xFF94A3B8);
  static const cardBg = Color(0xFF1A2535);
  static const cardBorder = Color(0xFF1E2D3D);
  static const green = Color(0xFF4ADE80);
  static const red = Color(0xFFF87171);
  static const muted = Color(0xFF3D5166);
}

class AppBarCustomized extends StatefulWidget implements PreferredSizeWidget {
  final double height;

  const AppBarCustomized({super.key, this.height = kToolbarHeight + 16});

  @override
  Size get preferredSize => Size.fromHeight(height);

  @override
  State<AppBarCustomized> createState() => _AppBarCustomizedState();
}

class _AppBarCustomizedState extends State<AppBarCustomized> {
  String _saludo = '';

  // ── Lifecycle ────────────────────────────────────────────────────────────────

  @override
  void initState() {
    super.initState();
    _saludo = _setSaludo();
    _actualizarSaludoCadaHora();
  }

  void _actualizarSaludoCadaHora() {
    final cron = Cron();
    cron.schedule(Schedule.parse('0 * * * *'), () async {
      if (mounted) setState(() => _saludo = _setSaludo());
    });
  }

  String _setSaludo() {
    final hour = DateTime.now().hour;
    if (hour >= 0 && hour < 12) return 'Buenos días,';
    if (hour >= 12 && hour < 19) return 'Buenas tardes,';
    return 'Buenas noches,';
  }

  // ── Badge de turno ────────────────────────────────────────────────────────────

  void _onBadgeTap() {
    final turno = context.read<TurnoProvider>();
    showModalBottomSheet(
      context: context,
      backgroundColor: _C.cardBg,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => _buildBottomSheetTurno(ctx, turno),
    );
  }

  Widget _buildBottomSheetTurno(BuildContext ctx, TurnoProvider turno) {
    return Consumer<TurnoProvider>(
      builder: (_, t, __) => Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
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

            // Estado actual
            if (t.sinIniciar) ...[
              _buildEstadoSinIniciar(ctx),
            ] else ...[
              _buildCronometro(t),
              const SizedBox(height: 16),
              if (t.activo) _buildBotonesActivo(ctx, t),
              if (t.pausado) _buildBotonesPausado(ctx, t),
            ],
          ],
        ),
      ),
    );
  }

  // ── Sin iniciar ───────────────────────────────────────────────────────────────

  Widget _buildEstadoSinIniciar(BuildContext ctx) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          'Sin turno activo',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: _C.primary,
          ),
        ),
        const SizedBox(height: 4),
        const Text(
          'Inicia tu turno para comenzar a registrar el tiempo',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 11, color: _C.secondary),
        ),
        const SizedBox(height: 20),
        GestureDetector(
          onTap: () async {
            await context.read<TurnoProvider>().iniciarTurno();
            if (mounted) Navigator.pop(ctx);
          },
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 13),
            decoration: BoxDecoration(
              color: _C.accent,
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.play_arrow_rounded,
                    color: Color(0xFF0F1923), size: 18),
                SizedBox(width: 8),
                Text('Iniciar turno',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF0F1923),
                    )),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // ── Cronómetro ────────────────────────────────────────────────────────────────

  Widget _buildCronometro(TurnoProvider t) {
    final esActivo = t.activo;
    return Column(
      children: [
        // Estado
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: esActivo
                ? _C.green.withOpacity(0.1)
                : _C.accent.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: esActivo
                  ? _C.green.withOpacity(0.3)
                  : _C.accent.withOpacity(0.3),
            ),
          ),
          child: Text(
            esActivo ? '● En turno' : '⏸ Pausado',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w500,
              color: esActivo ? _C.green : _C.accent,
            ),
          ),
        ),
        const SizedBox(height: 12),
        // Tiempo activo
        Text(
          t.tiempoFormateado,
          style: const TextStyle(
            fontSize: 36,
            fontWeight: FontWeight.w300,
            color: _C.primary,
            fontFeatures: [FontFeature.tabularFigures()],
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Tiempo activo',
          style: const TextStyle(fontSize: 10, color: _C.secondary),
        ),
        // Hora de inicio
        if (t.horaInicio != null) ...[
          const SizedBox(height: 4),
          Text(
            'Inicio: ${_formatHora(t.horaInicio!)}',
            style: const TextStyle(fontSize: 10, color: _C.muted),
          ),
        ],
        // Etiqueta de pausa activa
        if (t.pausado && t.etiquetaPausa != null) ...[
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: _C.accent.withOpacity(0.08),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: _C.accent.withOpacity(0.2)),
            ),
            child: Text(
              t.etiquetaPausa!,
              style: const TextStyle(fontSize: 10, color: _C.accent),
            ),
          ),
        ],
        // Pausas anteriores
        if (t.pausas.isNotEmpty) ...[
          const SizedBox(height: 8),
          Text(
            '${t.tiempoPausadoMinutos} min pausados · ${t.pausas.length} pausa(s)',
            style: const TextStyle(fontSize: 9, color: _C.muted),
          ),
        ],
      ],
    );
  }

  // ── Botones activo ────────────────────────────────────────────────────────────

  Widget _buildBotonesActivo(BuildContext ctx, TurnoProvider t) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Selector etiqueta de pausa
        const Text('Pausar por:',
            style: TextStyle(fontSize: 10, color: _C.secondary)),
        const SizedBox(height: 8),
        Wrap(
          spacing: 6,
          runSpacing: 6,
          children: etiquetasPausa.map((etiqueta) {
            return GestureDetector(
              onTap: () async {
                await context.read<TurnoProvider>().pausarTurno(etiqueta);
                if (mounted) Navigator.pop(ctx);
              },
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: _C.accent.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: _C.accent.withOpacity(0.2)),
                ),
                child: Text(etiqueta,
                    style: const TextStyle(fontSize: 11, color: _C.accent)),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 12),
        // Finalizar
        _buildBotonFinalizar(ctx, t),
      ],
    );
  }

  // ── Botones pausado ───────────────────────────────────────────────────────────

  Widget _buildBotonesPausado(BuildContext ctx, TurnoProvider t) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Reanudar
        GestureDetector(
          onTap: () async {
            await context.read<TurnoProvider>().reanudarTurno();
            if (mounted) Navigator.pop(ctx);
          },
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 13),
            decoration: BoxDecoration(
              color: _C.green.withOpacity(0.1),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: _C.green.withOpacity(0.3)),
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.play_arrow_rounded, color: _C.green, size: 18),
                SizedBox(width: 8),
                Text('Reanudar turno',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: _C.green,
                    )),
              ],
            ),
          ),
        ),
        const SizedBox(height: 8),
        // Finalizar
        _buildBotonFinalizar(ctx, t),
      ],
    );
  }

  // ── Botón finalizar compartido ────────────────────────────────────────────────

  Widget _buildBotonFinalizar(BuildContext ctx, TurnoProvider t) {
    return GestureDetector(
      onTap: () async {
        if (!mounted) return;

        final confirmar = await showDialog<bool>(
          context: context,
          builder: (dialogCtx) => AlertDialog(
            backgroundColor: _C.cardBg,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: const BorderSide(
                color: _C.cardBorder,
              ),
            ),
            title: const Text(
              '¿Finalizar turno?',
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
                onPressed: () => Navigator.pop(dialogCtx, true),
                child: const Text(
                  'Sí',
                  style: TextStyle(
                    color: _C.accent,
                  ),
                ),
              ),
              TextButton(
                onPressed: () => Navigator.pop(dialogCtx, false),
                child: const Text(
                  'No',
                  style: TextStyle(
                    color: _C.secondary,
                  ),
                ),
              ),
            ],
          ),
        );

        // Si eligió "No" o cerró el diálogo
        if (confirmar != true || !mounted) return;

        // Finalizar el turno y obtener sus datos
        // final datos = await context.read<TurnoProvider>().finalizarTurno();

        if (!mounted) return;

        // Cerrar el bottom sheet
        Navigator.pop(ctx);

        // Ir a la pantalla de liquidación/finalización
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => const StepperFinalized(),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 13),
        decoration: BoxDecoration(
          color: _C.red.withOpacity(0.08),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: _C.red.withOpacity(0.2),
          ),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.stop_rounded,
              color: _C.red,
              size: 18,
            ),
            SizedBox(width: 8),
            Text(
              'Finalizar turno',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: _C.red,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Helpers ───────────────────────────────────────────────────────────────────

  String _formatHora(DateTime hora) {
    final h = hora.hour.toString().padLeft(2, '0');
    final m = hora.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }

  // ── Build ─────────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return AppBar(
      toolbarHeight: widget.height,
      backgroundColor: const Color(0xFF0D1F2D),
      elevation: 0,
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(0),
        child: Container(height: 0.5, color: const Color(0xFF1E2D3D)),
      ),
      leading: Padding(
        padding: const EdgeInsets.only(left: 12, top: 6, bottom: 6),
        child: GestureDetector(
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const PerfilScreen()),
          ),
          child: const CircleAvatar(
            radius: kToolbarHeight,
            backgroundColor: Color(0xFFF5C518),
            backgroundImage: AssetImage('assets/images/perfil.jpg'),
            child: Text('J',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF0F1923),
                )),
          ),
        ),
      ),
      titleSpacing: 8,
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(_saludo,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w400,
                color: Color(0xFF94A3B8),
                height: 1.2,
              )),
          const Text('Julian',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Color(0xFFF1F5F9),
                height: 1.2,
              )),
        ],
      ),
      actions: [
        // Botón calendario
        GestureDetector(
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const TurneroScreen()),
          ),
          child: Container(
            width: 32,
            height: 32,
            margin: const EdgeInsets.only(right: 8),
            decoration: BoxDecoration(
              color: const Color(0xFFF5C518).withOpacity(0.1),
              borderRadius: BorderRadius.circular(9),
              border:
                  Border.all(color: const Color(0xFFF5C518).withOpacity(0.2)),
            ),
            child: const Icon(Icons.calendar_month_outlined,
                color: Color(0xFFF5C518), size: 15),
          ),
        ),
        // Badge turno — dinámico según estado
        Padding(
          padding: const EdgeInsets.only(right: 12),
          child: GestureDetector(
            onTap: _onBadgeTap,
            child: Consumer<TurnoProvider>(
              builder: (_, turno, __) {
                // Color y texto según estado
                Color color;
                String texto;
                if (turno.sinIniciar) {
                  color = _C.secondary;
                  texto = '○ Sin turno';
                } else if (turno.activo) {
                  color = _C.green;
                  texto = '● ${turno.tiempoFormateado}';
                } else {
                  color = _C.accent;
                  texto = '⏸ ${turno.tiempoFormateado}';
                }
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: color.withOpacity(0.3)),
                  ),
                  child: Text(
                    texto,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                      color: color,
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}
