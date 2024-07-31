import 'package:flutter/material.dart';

class BottomBar extends StatefulWidget {
  const BottomBar({super.key});

  @override
  State<BottomBar> createState() => _BottomBarState();
}

class _BottomBarState extends State<BottomBar> {
  int _paginaActual = 0;

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
        onTap: (index) {
          setState(() {
            _paginaActual = index;
          });
        },
        currentIndex: _paginaActual,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: "Inicio",
            backgroundColor: Colors.amber,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.list),
            label: "Ingresos",
            backgroundColor: Colors.purple,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.oil_barrel_sharp),
            label: "Consumos",
            backgroundColor: Colors.green,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.taxi_alert_rounded),
            label: "Fin Turno",
            backgroundColor: Colors.blue,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: "Config",
            backgroundColor: Colors.black,
          )
        ]);
  }
}

/*
    return BottomAppBar(
        shape: const CircularNotchedRectangle(),
        child: Row(
          children: [
            IconButton(
                icon: const Icon(Icons.home),
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) {
                    return const Home(0);
                  }));
                }),
            IconButton(
                icon: const Icon(Icons.list),
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) {
                    return const ListService();
                  }));
                }),
            //const Spacer(),
            IconButton(
                icon: const Icon(Icons.oil_barrel_sharp),
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) {
                    return const ListService();
                  }));
                }),
            IconButton(
                icon: const Icon(Icons.taxi_alert_rounded),
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) {
                    return const FinishTurn();
                  }));
                }),
            IconButton(
                icon: const Icon(Icons.settings),
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) {
                    return const Configuration();
                  }));
                }),
          ],
        ));
        */
