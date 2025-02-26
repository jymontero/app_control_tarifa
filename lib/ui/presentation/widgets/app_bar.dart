// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:cron/cron.dart';

class AppBarCustomized extends StatefulWidget implements PreferredSizeWidget {
  final double height;

  const AppBarCustomized({super.key, this.height = kToolbarHeight + 20});

  @override
  Size get preferredSize => Size.fromHeight(height);

  @override
  State<AppBarCustomized> createState() => _AppBarCustomizedState();
}

class _AppBarCustomizedState extends State<AppBarCustomized> {
  String saludo = "";

  @override
  void initState() {
    super.initState();
    saludo = setSaludo();
    actualizarSaludoCadaHora();
  }

  void actualizarSaludoCadaHora() {
    final cron = Cron();
    cron.schedule(Schedule.parse('0 * * * *'), () async {
      setState(() {
        saludo = setSaludo();
      });
    });
  }

  String setSaludo() {
    int hour = DateTime.now().hour;
    if (hour >= 0 && hour < 12) return "Buenos días,\n";
    if (hour >= 12 && hour < 19) return "Buenas tardes,\n";
    return "Buenas noches,\n";
  }

  @override
  Widget build(BuildContext context) {
    return AppBar(
      toolbarHeight: widget.height,
      backgroundColor: Colors.amber.shade600,
      leading: const SizedBox(
        height: kToolbarHeight,
        child: Center(
          child: CircleAvatar(
            radius: kToolbarHeight,
            backgroundImage: AssetImage("assets/images/perfil.jpg"),
          ),
        ),
      ),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            saludo,
            style: const TextStyle(
                fontSize: 18, fontWeight: FontWeight.w500, height: 0.5),
          ),
          const Text(
            "Julian",
            style:
                TextStyle(fontSize: 22, fontWeight: FontWeight.bold, height: 1),
          ),
        ],
      ),
      titleSpacing: 0.8,
    );
  }
}
