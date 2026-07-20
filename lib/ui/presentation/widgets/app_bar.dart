import 'package:flutter/material.dart';
import 'package:cron/cron.dart';
import 'package:taxi_servicios/ui/presentation/screens/screens_Perfil/perfil_screen.dart';

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
      if (mounted) {
        setState(() => _saludo = _setSaludo());
      }
    });
  }

  String _setSaludo() {
    final hour = DateTime.now().hour;
    if (hour >= 0 && hour < 12) return 'Buenos días,';
    if (hour >= 12 && hour < 19) return 'Buenas tardes,';
    return 'Buenas noches,';
  }

  // ── Build ─────────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return AppBar(
      toolbarHeight: widget.height,
      backgroundColor: const Color(0xFF0D1F2D),
      elevation: 0,
      // Borde inferior sutil
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(0),
        child: Container(
          height: 0.5,
          color: const Color(0xFF1E2D3D),
        ),
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
            // Si tienes foto de perfil usa backgroundImage
            backgroundImage: AssetImage('assets/images/perfil.jpg'),
            child: Text(
              'J',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Color(0xFF0F1923),
              ),
            ),
          ),
        ),
      ),
      titleSpacing: 8,
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            _saludo,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w400,
              color: Color(0xFF94A3B8),
              height: 1.2,
            ),
          ),
          const Text(
            'Julian',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Color(0xFFF1F5F9),
              height: 1.2,
            ),
          ),
        ],
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 12),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFFF5C518).withOpacity(0.12),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: const Color(0xFFF5C518).withOpacity(0.3),
              ),
            ),
            child: const Text(
              '● En turno',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w500,
                color: Color(0xFFF5C518),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
