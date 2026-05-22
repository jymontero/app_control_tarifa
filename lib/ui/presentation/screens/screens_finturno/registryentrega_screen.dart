import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pattern_formatter/pattern_formatter.dart';
import 'package:provider/provider.dart';
import 'package:taxi_servicios/providers/tanqueo_provider.dart';

// ── Paleta Dark Premium ───────────────────────────────────────────────────────
class _C {
  static const cardBorder = Color(0xFF1E2D3D);
  static const accent = Color(0xFFF5C518);
  static const primary = Color(0xFFF1F5F9);
  static const secondary = Color(0xFF94A3B8);
  static const muted = Color(0xFF3D5166);
}

class RegistryEntrega extends StatefulWidget {
  const RegistryEntrega({super.key});

  @override
  State<RegistryEntrega> createState() => _RegistryEntregaState();
}

class _RegistryEntregaState extends State<RegistryEntrega> {
  final TextEditingController _ctrl = TextEditingController(text: '');

  @override
  void initState() {
    super.initState();
    _ctrl.addListener(() {
      context.read<ServicioTanqueoProvider>().setvalorEntrega(_ctrl.text);
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.transparent,
      padding: const EdgeInsets.only(top: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Valor de entrega',
              style: TextStyle(fontSize: 10, color: _C.secondary)),
          const SizedBox(height: 5),
          Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.04),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: _C.accent.withOpacity(0.35)),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            child: Row(
              children: [
                const Icon(Icons.monetization_on_outlined,
                    color: _C.accent, size: 15),
                const SizedBox(width: 8),
                Expanded(
                  child: TextFormField(
                    controller: _ctrl,
                    keyboardType: TextInputType.number,
                    style: const TextStyle(color: _C.primary, fontSize: 13),
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      ThousandsFormatter(),
                    ],
                    decoration: const InputDecoration(
                      hintText: 'Ingresa el valor de entrega',
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
      ),
    );
  }
}
