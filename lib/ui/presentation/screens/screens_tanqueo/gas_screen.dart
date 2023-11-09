import 'package:flutter/material.dart';
import 'package:taxi_servicios/ui/presentation/screens/screens_EDS/listadoeds.dart';

class Gasoline extends StatefulWidget {
  const Gasoline({super.key});

  @override
  State<Gasoline> createState() => _GasolineState();
}

class _GasolineState extends State<Gasoline> {
  Widget _createCard() {
    return Card(
        elevation: 4.0,
        color: Colors.lightBlue[900],
        child: Column(
          children: [
            const SizedBox(
              height: 20,
            ),
            SizedBox(
              height: 110.0,
              child: Ink.image(
                image: const AssetImage("assets/images/primax.jpg"),
                fit: BoxFit.fill,
              ),
            ),
            ListTile(
              title: Text(
                'Texaco'.toUpperCase(),
                style: const TextStyle(
                    color: Colors.white, fontWeight: FontWeight.bold),
              ),
              subtitle: const Text(
                'Barrio Bolivar',
                style:
                    TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
              trailing: const Text(
                'COP 15.000',
                style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white),
              ),
            ),
          ],
        ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Column(
          children: [const SizedBox(height: 10), _createCard()],
        ),
        floatingActionButton: FloatingActionButton.extended(
          heroTag: 'btnEDS',
          backgroundColor: Colors.orange,
          onPressed: () {
            Navigator.push(context,
                MaterialPageRoute(builder: (context) => const ListEDS()));
          },
          // ignore: unnecessary_const
          icon: const Icon(Icons.playlist_add),
          label: const Text('Agregar EDS'),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat);
  }
}
