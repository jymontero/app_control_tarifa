// ignore_for_file: no_leading_underscores_for_local_identifiers, duplicate_ignore, avoid_print

import 'package:flutter/material.dart';
import 'package:taxi_servicios/ui/presentation/screens/registry_service_screen.dart';
import 'package:taxi_servicios/ui/presentation/screens/setup_screen.dart';
import 'package:taxi_servicios/ui/presentation/widgets/app_bar.dart';

import 'finish_screen.dart';
import 'gas_screen.dart';
import 'goaltaxes_screen.dart';
import 'list_services.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _Home createState() => _Home();
}

class _Home extends State<Home> {
  int _paginaActual = 0;

  final List<Widget> _pages = [
    const GoalDairy(),
    const ListService(),
    const Gasoline(),
    const FinishTurn(),
    const Configuration()
  ];

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // ignore: no_leading_underscores_for_local_identifiers

    return Scaffold(
      appBar: const AppBarCustomized(),
      body: _pages[_paginaActual],
      bottomNavigationBar: BottomNavigationBar(
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
              label: "Lista Servicios",
              backgroundColor: Colors.purple,
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.oil_barrel_sharp),
              label: "Gasolina",
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
          ]),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.amber.shade600,
        onPressed: () {
          Navigator.push(context,
              MaterialPageRoute(builder: (context) => const ServiceTaxi()));
        },
        child: const Icon(Icons.add),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}

    /*Widget _createInputService() {
      return Column(
        children: [
          TextField(
            autofocus: false,
            style: const TextStyle(color: Colors.white),
            controller: myController,
            keyboardType: TextInputType.number,
            inputFormatters: <TextInputFormatter>[
              FilteringTextInputFormatter.digitsOnly,
            ],
            decoration: const InputDecoration(
              hintText: 'Ingrese valor del servicio aqui',
              hintStyle: TextStyle(color: Colors.white),
              labelText: 'Valor',
              labelStyle: TextStyle(color: Colors.white),
              helperText: 'Ingrese valor del servicio',
              helperStyle: TextStyle(color: Colors.white),
            ),
          ),
        ],
      );
    }

    Widget _createRegistryButtom() {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ElevatedButton(
              style: ButtonStyle(
                foregroundColor: MaterialStateProperty.all(Colors.white),
              ),
              onPressed: () {
                setState(() {
                  if (myController.text == "") {
                    showAlert();
                  } else {
                    _costService = int.parse(myController.text);
                    showConfirmDialog();
                    _goal -= _costService;
                    _currentGoal += _costService;
                    // ignore: avoid_print
                    listServicesDay.add(_costService);
                  }
                });
                // ignore: avoid_print
                print('Lista de Servicios');
                for (var i in listServicesDay) {
                  print(i);
                }
                myController.clear();
              },
              child: const Text('Registrar',
                  style: TextStyle(
                    fontSize: 18,
                  )))
        ],
      );
    }*/

    

    /*Widget textFuture = Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildTextGoal(Colors.red, _metaPorCumplir),
      ],
    );*/

    /**Widget textActual = Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildTextGoal(Colors.lightGreenAccent.shade700, _metaRealizada),
      ],
    );**/

    /*Widget _textFuture(int metaCumplir){
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildTextGoal(Colors.red, metaCumplir),
        ],
      );
    }*/


/*
 ListView(children: [
        _createInfolabels("Meta"),
        _createLabelRate(_goal -= widget._valorServicio, 1),
        //_createInputService(),
        //_createRegistryButtom(),
        _createInfolabels("Meta Obtenida"),
        _createLabelRate(_currentGoal += widget._valorServicio, 0),
      ])
*/