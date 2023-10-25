import 'package:flutter/material.dart';
import 'package:taxi_servicios/ui/screens_EDS/registryeds.dart';

class Gasoline extends StatefulWidget {
  const Gasoline({super.key});

  @override
  State<Gasoline> createState() => _GasolineState();
}

class _GasolineState extends State<Gasoline> {
  Widget _createCard() {
    return Card(
        elevation: 4.0,
        child: Column(
          children: [
            const SizedBox(
              height: 20,
            ),
            SizedBox(
              height: 110.0,
              child: Ink.image(
                image: const AssetImage("assets/images/terpel.jpg"),
                fit: BoxFit.fill,
              ),
            ),
            const ListTile(
              title: Text('Primax'),
              subtitle: Text('Barrio Bolivar'),
              trailing: Text(
                'COP 15.000',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Column(
          children: [_createCard()],
        ),
        floatingActionButton: FloatingActionButton.extended(
          heroTag: 'btnEDS',
          backgroundColor: Colors.orange,
          onPressed: () {
            Navigator.push(context,
                MaterialPageRoute(builder: (context) => const RegistryEDS()));
          },
          // ignore: unnecessary_const
          icon: const Icon(Icons.playlist_add),
          label: const Text('Agregar EDS'),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat);
  }
}
