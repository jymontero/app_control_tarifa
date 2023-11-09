import 'package:flutter/material.dart';
import 'package:taxi_servicios/ui/presentation/screens/screens_EDS/registryeds.dart';
import 'package:taxi_servicios/ui/presentation/widgets/app_bar.dart';

class ListEDS extends StatefulWidget {
  const ListEDS({super.key});

  @override
  State<ListEDS> createState() => _ListEDSState();
}

class _ListEDSState extends State<ListEDS> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: const AppBarCustomized(),
        body: const Column(),
        floatingActionButton: FloatingActionButton.extended(
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
