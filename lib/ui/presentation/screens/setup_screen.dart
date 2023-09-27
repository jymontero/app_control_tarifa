import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:taxi_servicios/domain/entitis/variables.dart';
import 'package:taxi_servicios/providers/configuracion_provider.dart';

class Configuration extends StatefulWidget {
  const Configuration({super.key});

  @override
  State<Configuration> createState() => _ConfigurationState();
}

class _ConfigurationState extends State<Configuration> {
  final TextEditingController myControllerName =
      TextEditingController(text: "");
  final TextEditingController myControllerValue =
      TextEditingController(text: "");
  final _formKey = GlobalKey<FormState>();

  Widget _createForm() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextFormField(
            controller: myControllerName,
            validator: (controller) {
              if (controller == null || controller.isEmpty) {
                return 'Ingresa algun texto';
              }
              return null;
            },
          ),
          TextFormField(
            controller: myControllerValue,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Ingresa algun valor';
              }
              return null;
            },
          ),
        ],
      ),
    );
  }

  Widget _createRegistryButtom() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ElevatedButton(
            style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all(Colors.amber),
                foregroundColor: MaterialStateProperty.all(Colors.black),
                shape: MaterialStateProperty.all(RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5)))),
            onPressed: () {
              Variable variable = Variable(
                  valor: int.parse(myControllerValue.text),
                  nombre: myControllerName.text);
              if (_formKey.currentState!.validate()) {
                ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Procesando datos....')));
                context.read<ConfiguracionProvider>().addVariable(variable);
              }

              //Navigator.pop(context, int.parse(myController.text));
            },
            child: const Text('Agregar ',
                style: TextStyle(
                  fontSize: 18,
                )))
      ],
    );
  }

  Widget _createListVaraible(BuildContext context) {
    final listVariables = context.watch<ConfiguracionProvider>().listaVariables;
    return ListView.builder(
      itemCount: listVariables.length,
      itemBuilder: (BuildContext context, int index) {
        return ListTile(
            leading: const Icon(
              Icons.money_off,
              size: 30,
              color: Colors.green,
            ),
            title: Text(
              'COP ${listVariables[index].nombre}',
              style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black),
            ),
            subtitle: Text(
              '${listVariables[index].valor}',
              style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.normal,
                  color: Colors.black),
            ));
      },
    );
  }

  Column _buildTextGoal(Color color, int monto, double sizeLetter) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Padding(padding: EdgeInsets.all(10.0)),
        Text(
          'COP \$ $monto',
          style: TextStyle(
            fontSize: sizeLetter,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _createLabelRate(int metaActual, int flag) {
    if (flag == 0) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildTextGoal(Colors.lightGreenAccent.shade700, metaActual, 17),
        ],
      );
    } else {
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildTextGoal(Colors.red, metaActual, 20),
        ],
      );
    }
  }

  Widget _createInfolabels(String mensaje) {
    return Text(
      mensaje,
      textAlign: TextAlign.center,
      style: const TextStyle(color: Colors.black, fontSize: 16),
    );
  }

  Widget _createVariable(String name, int monto, IconData icono, Color color) {
    return Row(mainAxisAlignment: MainAxisAlignment.start, children: [
      Column(children: [
        Icon(
          icono,
          size: 50,
          color: color,
        ),
      ]),
      Column(children: [_createLabelRate(monto, 0), _createInfolabels(name)])
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SafeArea(
            child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          'Configuración De Variables',
          textAlign: TextAlign.center,
          style: TextStyle(
              fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black),
        ),
        _createForm(),

        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [_createRegistryButtom()],
        ),
        //const SizedBox(),

        /*const Padding(padding: EdgeInsets.all(20)),
        _createVariable('Entrega', 60000, Icons.money_off, Colors.green),
        _createVariable(
            'Gasolina', 60000, Icons.oil_barrel_rounded, Colors.red),
        _createVariable('Lavadero', 11000, Icons.wash, Colors.blue),
        _createVariable(
            'Sueldo', 134000, Icons.report_gmailerrorred, Colors.orange),*/
      ],
    )));
  }
}
