import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pattern_formatter/pattern_formatter.dart';
import 'package:taxi_servicios/domain/entitis/estaciongas.dart';
import 'package:taxi_servicios/services/bd_confi.dart';
import 'package:taxi_servicios/ui/presentation/widgets/app_bar.dart';

// ── Paleta Dark Premium ───────────────────────────────────────────────────────
class _C {
  static const bg = Color(0xFF0F1923);
  static const cardBorder = Color(0xFF1E2D3D);
  static const accent = Color(0xFFF5C518);
  static const primary = Color(0xFFF1F5F9);
  static const secondary = Color(0xFF94A3B8);
}

class EditEDS extends StatefulWidget {
  EstacionGas objEDS;
  EditEDS(this.objEDS, {super.key});

  @override
  State<EditEDS> createState() => _EditEDSState();
}

class _EditEDSState extends State<EditEDS> {
  final FireStoreDataBase _db = FireStoreDataBase();
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _ctrlNombre;
  late final TextEditingController _ctrlBarrio;
  late final TextEditingController _ctrlValor;

  @override
  void initState() {
    super.initState();
    _ctrlNombre = TextEditingController(text: widget.objEDS.nombre);
    _ctrlBarrio = TextEditingController(text: widget.objEDS.barrio);
    _ctrlValor =
        TextEditingController(text: widget.objEDS.valorgalon.toString());
  }

  @override
  void dispose() {
    _ctrlNombre.dispose();
    _ctrlBarrio.dispose();
    _ctrlValor.dispose();
    super.dispose();
  }

  // ── Actualizar ────────────────────────────────────────────────────────────────

  Future<void> _actualizarEDS() async {
    if (!_formKey.currentState!.validate()) return;

    final valor = int.parse(_ctrlValor.text.replaceAll(',', ''));

    final eds = EstacionGas(
      nombre: _ctrlNombre.text,
      barrio: _ctrlBarrio.text,
      valorgalon: valor,
    );
    eds.id = widget.objEDS.id;

    await _db.actualizarEDS(eds);

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('EDS actualizada correctamente'),
        backgroundColor: Color(0xFF1A2535),
      ),
    );
    Navigator.pop(context);
  }

  // ── Build ─────────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AppBarCustomized(),
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
                _buildCampo(
                  label: 'Nombre de la EDS',
                  icono: Icons.local_gas_station_rounded,
                  controller: _ctrlNombre,
                  inputType: TextInputType.text,
                  capitalizacion: TextCapitalization.sentences,
                  validator: (v) =>
                      v == null || v.isEmpty ? 'Ingresa el nombre' : null,
                ),
                const SizedBox(height: 10),
                _buildCampo(
                  label: 'Barrio',
                  icono: Icons.location_city_outlined,
                  controller: _ctrlBarrio,
                  inputType: TextInputType.text,
                  capitalizacion: TextCapitalization.words,
                  validator: (v) =>
                      v == null || v.isEmpty ? 'Ingresa el barrio' : null,
                ),
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
                  'Editar estación',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: _C.primary,
                  ),
                ),
              ],
            ),
            const Text(
              'Modifica los datos de la EDS',
              style: TextStyle(fontSize: 10, color: _C.secondary),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildCampo({
    required String label,
    required IconData icono,
    required TextEditingController controller,
    required TextInputType inputType,
    required TextCapitalization capitalizacion,
    required FormFieldValidator<String> validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 10, color: _C.secondary)),
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
              Icon(icono, color: _C.accent, size: 15),
              const SizedBox(width: 8),
              Expanded(
                child: TextFormField(
                  controller: controller,
                  keyboardType: inputType,
                  textCapitalization: capitalizacion,
                  style: const TextStyle(color: _C.primary, fontSize: 13),
                  validator: validator,
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
        const Text('Valor del galón',
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
                      fontWeight: FontWeight.w500),
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
      onTap: _actualizarEDS,
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
              'Actualizar EDS',
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
