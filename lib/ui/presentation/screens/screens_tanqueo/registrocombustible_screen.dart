import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:pattern_formatter/pattern_formatter.dart';
import 'package:provider/provider.dart';
import 'package:taxi_servicios/providers/tanqueo_provider.dart';
import 'package:taxi_servicios/services/bd_confi.dart';
import 'package:taxi_servicios/ui/presentation/widgets/calculadora.dart';

// ── Paleta Dark Premium ───────────────────────────────────────────────────────
class _C {
  static const bg = Color(0xFF0F1923);
  static const cardBg = Color(0xFF1A2535);
  static const cardBorder = Color(0xFF1E2D3D);
  static const accent = Color(0xFFF5C518);
  static const primary = Color(0xFFF1F5F9);
  static const secondary = Color(0xFF94A3B8);
  static const muted = Color(0xFF3D5166);
}

class RegistroCombustible extends StatefulWidget {
  const RegistroCombustible({super.key});

  @override
  State<RegistroCombustible> createState() => _RegistroCombustibleState();
}

class _RegistroCombustibleState extends State<RegistroCombustible> {
  final FireStoreDataBase _db = FireStoreDataBase();

  TextEditingController _ctrlValorTanqueo = TextEditingController(text: '0.0');
  TextEditingController _ctrlGalones = TextEditingController(text: '# Galones');
  final TextEditingController _ctrlKm = TextEditingController(text: '');

  final _fmt =
      NumberFormat.currency(locale: 'es_MX', symbol: '', decimalDigits: 0);

  @override
  void initState() {
    super.initState();
    _ctrlValorTanqueo.addListener(() {
      context
          .read<ServicioTanqueoProvider>()
          .setvalorTanqueo(_ctrlValorTanqueo.text);
    });
    _ctrlGalones.addListener(() {
      context
          .read<ServicioTanqueoProvider>()
          .setvalorGalones(_ctrlGalones.text);
    });
    _ctrlKm.addListener(() {
      context.read<ServicioTanqueoProvider>().setvalorKilometraje(_ctrlKm.text);
    });
  }

  @override
  void dispose() {
    _ctrlValorTanqueo.dispose();
    _ctrlGalones.dispose();
    _ctrlKm.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.transparent,
      padding: const EdgeInsets.only(top: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Valor del tanqueo
          _buildCampoTap(
            label: 'Valor del tanqueo',
            icono: Icons.monetization_on_outlined,
            valor:
                '\$${_fmt.format(int.tryParse(_ctrlValorTanqueo.text.replaceAll('.0', '')) ?? 0)}',
            onTap: () async {
              final ctrl = await Navigator.push<TextEditingController>(
                context,
                MaterialPageRoute(
                    builder: (_) => Calculadora(_ctrlValorTanqueo)),
              );
              if (ctrl != null && mounted) {
                setState(() {
                  _ctrlValorTanqueo = ctrl;
                  context
                      .read<ServicioTanqueoProvider>()
                      .setvalorTanqueo(ctrl.text.replaceAll('.0', ''));
                });
              }
            },
          ),
          const SizedBox(height: 6),

          // Galones
          _buildCampoTap(
            label: 'Galones',
            icono: Icons.local_gas_station_outlined,
            valor: _ctrlGalones.text == '# Galones'
                ? '# Galones'
                : _ctrlGalones.text,
            onTap: () async {
              final ctrl = await Navigator.push<TextEditingController>(
                context,
                MaterialPageRoute(builder: (_) => Calculadora(_ctrlGalones)),
              );
              if (ctrl != null && mounted) {
                setState(() {
                  _ctrlGalones = ctrl;
                  context
                      .read<ServicioTanqueoProvider>()
                      .setvalorGalones(ctrl.text);
                });
              }
            },
          ),
          const SizedBox(height: 6),

          // Kilometraje
          _buildCampoKm(),
        ],
      ),
    );
  }

  // ── Campo tap (abre calculadora) ──────────────────────────────────────────────

  Widget _buildCampoTap({
    required String label,
    required IconData icono,
    required String valor,
    required VoidCallback onTap,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 10, color: _C.secondary)),
        const SizedBox(height: 2),
        GestureDetector(
          onTap: onTap,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.04),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: _C.accent.withOpacity(0.35)),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
            child: Row(
              children: [
                Icon(icono, color: _C.accent, size: 15),
                const SizedBox(width: 6),
                Text(
                  valor,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: _C.primary,
                  ),
                ),
                const Spacer(),
                const Icon(Icons.edit_outlined, color: _C.muted, size: 13),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // ── Campo kilometraje ─────────────────────────────────────────────────────────

  Widget _buildCampoKm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Kilometraje',
            style: TextStyle(fontSize: 10, color: _C.secondary)),
        const SizedBox(height: 6),
        Container(
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.04),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: _C.cardBorder),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          child: Row(
            children: [
              const Icon(Icons.speed_outlined, color: _C.accent, size: 15),
              const SizedBox(width: 6),
              Expanded(
                child: TextFormField(
                  controller: _ctrlKm,
                  keyboardType: TextInputType.number,
                  style: const TextStyle(color: _C.primary, fontSize: 13),
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    ThousandsFormatter(),
                  ],
                  decoration: const InputDecoration(
                    hintText: 'Ingresa el kilometraje',
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
}
