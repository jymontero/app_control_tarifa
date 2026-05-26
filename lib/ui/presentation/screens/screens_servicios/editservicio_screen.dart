// ignore_for_file: must_be_immutable

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pattern_formatter/pattern_formatter.dart';
import 'package:provider/provider.dart';
import 'package:taxi_servicios/domain/entitis/servicio.dart';
import 'package:taxi_servicios/providers/contadordeservicios_provider.dart';
import 'package:taxi_servicios/services/bd_confi.dart';

// ── Paleta Dark Premium ───────────────────────────────────────────────────────
class _C {
  static const bg = Color(0xFF0F1923);
  static const cardBg = Color(0xFF1A2535);
  static const cardBorder = Color(0xFF1E2D3D);
  static const accent = Color(0xFFF5C518);
  static const primary = Color(0xFFF1F5F9);
  static const secondary = Color(0xFF64748B);
  static const muted = Color(0xFF3D5166);
  static const green = Color(0xFF4ADE80);
  static const red = Color(0xFFF87171);
}

class EditService extends StatefulWidget {
  Servicio objServicio;
  EditService(this.objServicio, {super.key});

  @override
  State<EditService> createState() => _EditServiceState();
}

class _EditServiceState extends State<EditService> {
  final _controller = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final _db = FireStoreDataBase();

  late String _tipoServicio;
  late String _metodoPago;

  @override
  void initState() {
    super.initState();
    _controller.text = widget.objServicio.valorservicio.toString();
    _tipoServicio = widget.objServicio.tipoServicio;
    _metodoPago = widget.objServicio.metodoPago;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  // ── Guardar ──────────────────────────────────────────────────────────────────

  Future<void> _actualizarServicio() async {
    if (!_formKey.currentState!.validate()) return;

    final valor = int.parse(_controller.text.replaceAll(',', ''));

    // Crear servicio actualizado conservando campos existentes
    final servicioActualizado = Servicio(
      valorservicio: valor,
      hora: widget.objServicio.hora,
      fecha: widget.objServicio.fecha,
      facturada: widget.objServicio.facturada,
      tipoServicio: _tipoServicio,
      metodoPago: _metodoPago,
    );
    servicioActualizado.id = widget.objServicio.id;

    await _db.actualizarServicio(servicioActualizado);

    if (!mounted) return;

    // Actualizar providers
    final contador = context.read<ContadorServicioProvider>();
    contador.decrementarMetaPorHacer(valor);
    contador.sumarMetaPorHacer(widget.objServicio.valorservicio);
    contador.decrementarMetaObtendia(widget.objServicio.valorservicio);
    contador.incrementarMetaObtenida(valor);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Servicio actualizado correctamente'),
        backgroundColor: Color(0xFF1A2535),
      ),
    );

    Navigator.pop(context);
  }

  // ── Build ────────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _C.bg,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 16),
                _buildTitulo(),
                const SizedBox(height: 16),
                _buildToggleTipoServicio(),
                const SizedBox(height: 10),
                _buildToggleMetodoPago(),
                const SizedBox(height: 10),
                _buildCampoValor(),
                const SizedBox(height: 10),
                _buildInfoReadOnly(
                  label: 'Hora del viaje',
                  valor: widget.objServicio.hora,
                  icono: Icons.access_time_rounded,
                ),
                const SizedBox(height: 10),
                _buildInfoReadOnly(
                  label: 'Fecha del turno',
                  valor: widget.objServicio.fecha,
                  icono: Icons.calendar_today_outlined,
                ),
                const SizedBox(height: 14),
                _buildBotonActualizar(),
                const SizedBox(height: 8),
                _buildBotonCancelar(),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ── Widgets ──────────────────────────────────────────────────────────────────

  Widget _buildTitulo() {
    return Row(
      children: [
        Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            color: _C.accent.withOpacity(0.1),
            borderRadius: BorderRadius.circular(9),
          ),
          child: const Icon(Icons.edit_outlined, color: _C.accent, size: 16),
        ),
        const SizedBox(width: 10),
        const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Editar servicio',
                style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: _C.primary)),
            Text('Modifica los datos del viaje',
                style: TextStyle(fontSize: 10, color: _C.muted)),
          ],
        ),
      ],
    );
  }

  Widget _buildToggle({
    required String label,
    required List<String> opciones,
    required List<String> etiquetas,
    required List<IconData> iconos,
    required String seleccionado,
    required ValueChanged<String> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 10, color: _C.muted)),
        const SizedBox(height: 5),
        Container(
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.03),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: _C.cardBorder),
          ),
          padding: const EdgeInsets.all(5),
          child: Row(
            children: List.generate(opciones.length, (i) {
              final isActive = seleccionado == opciones[i];
              return Expanded(
                child: GestureDetector(
                  onTap: () => onChanged(opciones[i]),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      color: isActive ? _C.accent : Colors.transparent,
                      borderRadius: BorderRadius.circular(9),
                      border:
                          isActive ? null : Border.all(color: _C.cardBorder),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(iconos[i],
                            size: 13,
                            color:
                                isActive ? const Color(0xFF0F1923) : _C.muted),
                        const SizedBox(width: 5),
                        Text(etiquetas[i],
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                              color:
                                  isActive ? const Color(0xFF0F1923) : _C.muted,
                            )),
                      ],
                    ),
                  ),
                ),
              );
            }),
          ),
        ),
      ],
    );
  }

  Widget _buildToggleTipoServicio() {
    return _buildToggle(
      label: 'Tipo de servicio',
      opciones: ['taxi', 'plataforma'],
      etiquetas: ['Taxi', 'Plataforma'],
      iconos: [Icons.local_taxi_rounded, Icons.phone_android_outlined],
      seleccionado: _tipoServicio,
      onChanged: (v) => setState(() => _tipoServicio = v),
    );
  }

  Widget _buildToggleMetodoPago() {
    return _buildToggle(
      label: 'Método de pago',
      opciones: ['efectivo', 'transferencia'],
      etiquetas: ['Efectivo', 'Transferencia'],
      iconos: [Icons.payments_outlined, Icons.swap_horiz_rounded],
      seleccionado: _metodoPago,
      onChanged: (v) => setState(() => _metodoPago = v),
    );
  }

  Widget _buildCampoValor() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Valor del servicio',
            style: TextStyle(fontSize: 10, color: _C.muted)),
        const SizedBox(height: 5),
        Container(
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.04),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: _C.accent.withOpacity(0.4)),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          child: Row(
            children: [
              const Icon(Icons.monetization_on_outlined,
                  color: _C.accent, size: 16),
              const SizedBox(width: 8),
              Expanded(
                child: TextFormField(
                  controller: _controller,
                  keyboardType: TextInputType.number,
                  style: const TextStyle(
                    color: _C.primary,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    ThousandsFormatter(),
                  ],
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Ingresa algún valor';
                    }
                    return null;
                  },
                  decoration: const InputDecoration(
                    hintText: 'Valor del servicio',
                    hintStyle: TextStyle(color: _C.muted, fontSize: 11),
                    border: InputBorder.none,
                    isDense: true,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildInfoReadOnly({
    required String label,
    required String valor,
    required IconData icono,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 10, color: _C.muted)),
        const SizedBox(height: 5),
        Container(
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.04),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: _C.cardBorder),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
          child: Row(
            children: [
              Icon(icono, color: _C.accent, size: 14),
              const SizedBox(width: 8),
              Text(valor,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: _C.primary,
                  )),
              const Spacer(),
              const Text('No editable',
                  style: TextStyle(fontSize: 9, color: _C.muted)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBotonActualizar() {
    return GestureDetector(
      onTap: _actualizarServicio,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 13),
        decoration: BoxDecoration(
          color: _C.accent,
          borderRadius: BorderRadius.circular(14),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.check_rounded, color: Color(0xFF0F1923), size: 16),
            SizedBox(width: 8),
            Text('Actualizar servicio',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF0F1923),
                )),
          ],
        ),
      ),
    );
  }

  Widget _buildBotonCancelar() {
    return GestureDetector(
      onTap: () => Navigator.pop(context),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 11),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.03),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: _C.cardBorder),
        ),
        child: const Center(
          child:
              Text('Cancelar', style: TextStyle(fontSize: 12, color: _C.muted)),
        ),
      ),
    );
  }
}
