// ignore_for_file: must_be_immutable

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pattern_formatter/pattern_formatter.dart';
import 'package:provider/provider.dart';
import 'package:taxi_servicios/domain/entitis/variables.dart';
import 'package:taxi_servicios/providers/configuracion_provider.dart';
import 'package:taxi_servicios/providers/contadordeservicios_provider.dart';
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
  static const red = Color(0xFFF87171);
}

class EditVariable extends StatefulWidget {
  Variable objVariable;
  EditVariable(this.objVariable, {super.key});

  @override
  State<EditVariable> createState() => _EditVariableState();
}

class _EditVariableState extends State<EditVariable> {
  final _formKey = GlobalKey<FormState>();
  final FireStoreDataBase _db = FireStoreDataBase();

  late final TextEditingController _ctrlNombre;
  late final TextEditingController _ctrlValor;

  @override
  void initState() {
    super.initState();
    _ctrlNombre = TextEditingController(text: widget.objVariable.nombre);
    _ctrlValor =
        TextEditingController(text: widget.objVariable.valor.toString());
  }

  @override
  void dispose() {
    _ctrlNombre.dispose();
    _ctrlValor.dispose();
    super.dispose();
  }

  // ── Actualizar ────────────────────────────────────────────────────────────────

  Future<void> _actualizarVariable() async {
    if (!_formKey.currentState!.validate()) return;

    final int valor = int.parse(_ctrlValor.text.replaceAll(',', ''));

    final variable = Variable(
      valor: valor,
      nombre: _ctrlNombre.text.trim(),
    );
    variable.id = widget.objVariable.id;

    await _db.actualizarVariable(variable);

    if (!mounted) return;

    // Actualizar providers
    context
        .read<ConfiguracionProvider>()
        .restaVariable(widget.objVariable.valor);
    context.read<ConfiguracionProvider>().sumarVariable(valor);
    context
        .read<ContadorServicioProvider>()
        .decrementarMetaPorHacer(widget.objVariable.valor);
    context.read<ContadorServicioProvider>().sumarMetaPorHacer(valor);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: const Color(0xFF1A2535),
        elevation: 0,
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 20),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: BorderSide(
            color: _C.accent.withOpacity(0.25),
          ),
        ),
        content: const Row(
          children: [
            Icon(
              Icons.check_circle_rounded,
              color: _C.accent,
              size: 20,
            ),
            SizedBox(width: 12),
            Expanded(
              child: Text(
                'Variable actualizada correctamente',
                style: TextStyle(
                  color: Color(0xFFF1F5F9),
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        duration: const Duration(seconds: 5),
      ),
    );
    Navigator.pop(context);
  }

  // ── Build ─────────────────────────────────────────────────────────────────────

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
                _buildHeader(),
                const SizedBox(height: 20),
                _buildCampoNombre(),
                const SizedBox(height: 10),
                _buildCampoValor(),
                const SizedBox(height: 20),
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

  Widget _buildHeader() {
    return Row(
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
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: _C.accent.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(7),
                  ),
                  child: const Icon(Icons.edit_outlined,
                      color: _C.accent, size: 14),
                ),
                const SizedBox(width: 8),
                const Text(
                  'Editar variable',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: _C.primary,
                  ),
                ),
              ],
            ),
            const Text(
              'Modifica los datos de la variable',
              style: TextStyle(fontSize: 10, color: _C.secondary),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildCampoNombre() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Nombre de la variable',
            style: TextStyle(fontSize: 10, color: _C.secondary)),
        const SizedBox(height: 5),
        Container(
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.04),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: _C.cardBorder),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          child: Row(
            children: [
              const Icon(Icons.label_outline_rounded,
                  color: _C.accent, size: 15),
              const SizedBox(width: 8),
              Expanded(
                child: TextFormField(
                  controller: _ctrlNombre,
                  keyboardType: TextInputType.text,
                  textCapitalization: TextCapitalization.sentences,
                  style: const TextStyle(color: _C.primary, fontSize: 13),
                  validator: (v) =>
                      v == null || v.isEmpty ? 'Ingresa el nombre' : null,
                  decoration: const InputDecoration(
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

  Widget _buildCampoValor() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Valor',
            style: TextStyle(fontSize: 10, color: _C.secondary)),
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
                  color: _C.accent, size: 15),
              const SizedBox(width: 8),
              Expanded(
                child: TextFormField(
                  controller: _ctrlValor,
                  keyboardType: TextInputType.number,
                  style: const TextStyle(
                    color: _C.primary,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    ThousandsFormatter(),
                  ],
                  validator: (v) =>
                      v == null || v.isEmpty ? 'Ingresa el valor' : null,
                  decoration: const InputDecoration(
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

  Widget _buildBotonActualizar() {
    return GestureDetector(
      onTap: _actualizarVariable,
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
            Text(
              'Actualizar variable',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: Color(0xFF0F1923),
              ),
            ),
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
          child: Text('Cancelar',
              style: TextStyle(fontSize: 12, color: _C.secondary)),
        ),
      ),
    );
  }
}
