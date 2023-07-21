// ignore_for_file: no_leading_underscores_for_local_identifiers, duplicate_ignore, avoid_print

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:quickalert/quickalert.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _Home createState() => _Home();
}

class _Home extends State<Home> {
  late int _costService = 0;
  late int _goal = 260000;
  late int _currentGoal = 0;
  List<int> listServicesDay = [];

  final myController = TextEditingController();

  @override
  void dispose() {
    myController.dispose();
    super.dispose();
  }

  void showAlert() {
    QuickAlert.show(context: context, type: QuickAlertType.warning);
  }

  @override
  Widget build(BuildContext context) {
    // ignore: no_leading_underscores_for_local_identifiers
    Column _buildTextGoal(Color color, int monto) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Padding(padding: EdgeInsets.all(10.0)),
          Text(
            'COP \$$monto',
            style: TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      );
    }

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

    Widget _createInfolabels(String mensaje) {
      return Text(
        mensaje,
        textAlign: TextAlign.center,
        style: const TextStyle(color: Colors.white, fontSize: 14),
      );
    }

    Widget _createLabelRate(int metaActual, int flag) {
      if (flag == 0) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildTextGoal(Colors.lightGreenAccent.shade700, metaActual),
          ],
        );
      } else {
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildTextGoal(Colors.red, metaActual),
          ],
        );
      }
    }

    Widget _createInputService() {
      return Column(
        children: [
          TextField(
            style: const TextStyle(color: Colors.white),
            controller: myController,
            keyboardType: TextInputType.number,
            inputFormatters: <TextInputFormatter>[
              FilteringTextInputFormatter.digitsOnly,
            ],
            decoration: InputDecoration(
              icon: const Icon(Icons.attach_money_rounded),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15.0),
              ),
              hintText: 'Ingrese valor del servicio aqui',
              hintStyle: const TextStyle(color: Colors.white),
              labelText: 'Valor',
              labelStyle: const TextStyle(color: Colors.white),
              helperText: 'Ingrese valor del servicio',
              helperStyle: const TextStyle(color: Colors.white),
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
    }

    return Scaffold(
      appBar: AppBar(
          toolbarHeight: 75,
          title: const Text(
            'Servicios Taxi 673',
          ),
          titleSpacing: 5.0,
          centerTitle: true,
          backgroundColor: Colors.black87),
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/images/fondo3.jpg"),
            fit: BoxFit.cover,
          ),
        ),
        child: ListView(children: [
          _createLabelRate(_goal, 1),
          _createInfolabels("Meta"),
          _createInputService(),
          _createRegistryButtom(),
          _createLabelRate(_currentGoal, 0),
          _createInfolabels("Meta Obtenida"),
        ]),
      ),
      bottomNavigationBar: BottomAppBar(
          shape: const CircularNotchedRectangle(),
          child: Container(
            height: 50.0,
          )),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.black,
        onPressed: () {
          // ignore: avoid_print
          print('BotonOprimido');
        },
        child: const Icon(Icons.add),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }
}
