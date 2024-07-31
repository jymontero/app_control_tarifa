// ignore_for_file: avoid_print

import 'package:cron/cron.dart';
import 'package:flutter/material.dart';

class AppBarCustomized extends StatefulWidget implements PreferredSizeWidget {
  final double height;

  const AppBarCustomized({super.key, this.height = kToolbarHeight + 40});

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
  }

  Widget getSaludo(String saludo) {
    return Text(
      saludo,
      textAlign: TextAlign.left,
      style: const TextStyle(fontSize: 25),
    );
  }

  String setSaludo() {
    var timer = DateTime.now();
    var hour = timer.hour;
    print(hour);
    if (hour >= 00 && hour < 12) {
      saludo = "Buenos dias,\n";
    }
    if (hour >= 12 && hour < 19) {
      saludo = "Buenas tardes,\n";
    }
    if (hour >= 19 && hour <= 23) {
      saludo = "Buenas noches,\n";
    }

    return saludo;
  }

  @override
  Widget build(BuildContext context) {
    final cron = Cron();

    cron.schedule(Schedule.parse('0 * * * *'), () async {
      setSaludo();
      setState(() {
        saludo = setSaludo();
      });
    });

    return AppBar(
      backgroundColor: Colors.amber,
      leading: const Padding(
        padding: EdgeInsets.all(1.0),
        child: CircleAvatar(
          backgroundImage: AssetImage("assets/images/perfil.jpg"),
        ),
      ),
      title: Padding(
        padding: const EdgeInsets.all(5),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              '${saludo}Julian',
              textAlign: TextAlign.left,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
      titleSpacing: 5.0,
    );
  }
}
